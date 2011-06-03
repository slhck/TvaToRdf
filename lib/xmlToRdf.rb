require_relative 'options'
require 'pp'
require 'rdf'
require 'rdf/n3'
require 'rexml/document'
require 'uuid'
include REXML
include RDF

module TvaToRdf

class XmlToRdf
  
  attr_accessor :program_nodes_count, :schedule_nodes_count
  
  def initialize(xml, filmlist = nil)
    # Initialize vocabularies
    @po = Vocabulary.new("http://purl.org/ontology/po/")  # => The programme ontology
    @tl = Vocabulary.new("http://purl.org/NET/c4dm/timeline.owl#")  # => External vocabularies
    @self = "http://example.com/rdf/"     # => The prefix for self created URIs
    
    # The TVA XML document 
    @xml = xml
    
    # The RDF list of films
    @filmlist = filmlist unless filmlist.nil?
    
    # Set up iterators
    @program_nodes_count = 0
    @program_nodes_iterator = 0
    @schedule_nodes_iterator = 0
    @schedule_nodes_count = 0
  end
  
  
  # -------------------------------------------------------------------
  def parse_from_file

    info "Creating statements for Services..."
    
    @statements = Array.new
    
    # Iterate over services
    @xml.root.each_element("//ServiceInformation") do |service_info|
      @statements += parse_service_information(service_info)
    end
    
    # Iterate over programs
    info "Creating statements for Programmes..."
    @program_nodes_count = XPath.first(@xml.root, 'count(//ProgramInformation)')
    debug "There are " + @program_nodes_count.to_s + " program entries to consider"
    @xml.root.each_element("//ProgramInformation") do |program_information|
      @statements += parse_program_information(program_information)
    end
    
    # Iterate over schedule
    info "Creating statements for Schedule..."
    @schedule_nodes_count = XPath.first(@xml.root, 'count(//Schedule)')
    debug "There are " + @schedule_nodes_count.to_s + " schedule entries to consider"
    @xml.root.each_element("//Schedule") do |schedule|
      @statements += parse_schedule_information(schedule)
    end
    
    info "Total statements: #{@statements.size}"
    
  end
  
  # -------------------------------------------------------------------
  def parse_service_information(service_info)
    statements = Array.new
    
    attr_id = service_info.attributes['serviceId']
    attr_url = service_info.elements['ServiceURL'].text
    attr_owner = service_info.elements['Owner'].text
    
    serv = RDF::URI.new(@self + attr_id)
    broadcaster = RDF::URI.new(@self + attr_owner)
    channel = RDF::URI.new(attr_url)
    
    # Service is of the type Service
    statements.push Statement.new :subject => serv, :predicate => RDF.type, :object => @po.Service
    
    # Service is broadcasted by some broadcaster identified by its name
    statements.push Statement.new :subject => serv, :predicate => @po.broadcaster, :object => broadcaster
    
    # Service is seen on a channel identified by its URI (e.g. dvb://...)
    statements.push Statement.new :subject => serv, :predicate => @po.channel, :object => channel
    
    statements
  end

  # -------------------------------------------------------------------  
  def parse_program_information(program_information)
    statements = Array.new
    
    @program_nodes_iterator += 1
    debug "Processing Program #{@program_nodes_iterator} of #{@program_nodes_count}"  
    
    attr_crid = program_information.attributes["programId"]
    attr_title = program_information.elements['BasicDescription/Title'].text rescue "No Title"
    attr_synopsis = program_information.elements['BasicDescription/Synopsis'].text rescue "No Synopsis"  
    
    genre_node = program_information.elements['BasicDescription/Genre']
    unless genre_node.nil?
      attr_genre_urn = program_information.elements['BasicDescription/Genre'].attributes['href']
      attr_genre_name = program_information.elements['BasicDescription/Genre/Name'].text rescue "No Name"
    end
    
    program = RDF::URI.new(attr_crid)
    
    # A program is essentially an Episode (no further details here)
    statements.push Statement.new :subject => program, :predicate => RDF.type, :object => @po.Episode
    
    # Add title and synopsis
    statements.push Statement.new :subject => program, :predicate => DC.title, :object => Literal.new(attr_title)
    statements.push Statement.new :subject => program, :predicate => @po.synopsis, :object => Literal.new(attr_synopsis)
    statements.push Statement.new :subject => program, :predicate => @po.short_synopsis, :object => Literal.new(attr_synopsis)
    statements.push Statement.new :subject => program, :predicate => @po.medium_synopsis, :object => Literal.new(attr_synopsis)
    
    # Add genre (but only if it was specified at all)
    unless genre_node.nil?
      statements.push Statement.new :subject => program, :predicate => @po.genre, :object => RDF::URI.new(attr_genre_urn)
    end
    
    if @filmlist
      # Find corresponding film, this is really stupid and inefficient, but the checking should be simple
      @filmlist.root.each_element("movie:film") do |film|
        if attr_title.downcase.strip == film.elements['rdfs:label'].text.downcase.strip
          
          info "Match found between " + attr_title.strip + " and " + film.elements['rdfs:label'].text.strip
          info "URI for match: " + film.attributes['rdf:about']
          
          statements.push Statement.new :subject => program, :predicate => RDFS.seeAlso, :object => RDF::URI.new(film.attributes['rdf:about'])
        end
      end
    end
      
    
    statements
  end
  
  # ----------------------------------------------------------------------
  def parse_schedule_information(schedule) 
    statements = Array.new
    
    @schedule_nodes_iterator += 1
    debug "Processing Schedule #{@schedule_nodes_iterator} of #{@schedule_nodes_count}"  
    
    attr_crid = schedule.elements['ScheduleEvent'].elements['Program'].attributes['crid']
    attr_service = schedule.attributes['serviceIDRef']
    attr_start = schedule.elements['ScheduleEvent'].elements['PublishedStartTime'].text
    attr_end = schedule.elements['ScheduleEvent'].elements['PublishedEndTime'].text

    program = RDF::URI.new(attr_crid)
    serv = RDF::URI.new(@self + attr_service)

    # A program is bound to one service
    statements.push Statement.new :subject => program, :predicate => @po.service, :object => serv

    # Create Version and Broadcast, here as a blank node because we don't have any additional information
    # TODO maybe have another representation?
    version = Node.uuid()
    broadcast = Node.uuid()

    # A program is broadcast as a broadcast certain service
    statements.push Statement.new :subject => version, :predicate => @po.broadcast, :object => broadcast
    statements.push Statement.new :subject => broadcast, :predicate => @po.broadcast_on, :object => serv

    # Create the timeline as a blank node, only with start and end
    interval = Node.uuid()
    statements.push Statement.new :subject => interval, :predicate => RDF.type, :object => @tl.interval
    statements.push Statement.new :subject => interval, :predicate => @tl.start, :object => Literal.new(attr_start, :datatype => XSD.dateTime)
    statements.push Statement.new :subject => interval, :predicate => @tl.end, :object => Literal.new(attr_end, :datatype => XSD.dateTime)

    # Hook the timeline to the broadcast
    statements.push Statement.new :subject => broadcast, :predicate => @po.time, :object => interval
    
    statements
  end
  
  def serialize_to_file(file)
    RDF::Writer.open(file) do |writer|
      writer << Graph.new do |graph|
        @statements.each_with_index do |statement|
          graph << statement
        end
      end
    end
  end
  
  # ----------------------------------------------
  # Helper methods
  
  def info(msg)
    puts "INFO\t#{msg}"
  end
  
  def debug(msg)
    puts "DEBUG\t#{msg}" if $verbose
  end
  
  def error(msg, e)
    $stderr.puts "ERROR\t#{msg} #{e}"
  end
  
end

end