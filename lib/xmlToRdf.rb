require_relative 'options'
require 'pp'
require 'rdf'
require 'rdf/n3'
require 'rexml/document'
require 'uuid'
include REXML
include RDF


class XmlToRdf
  
  def initialize(xml)
    @po = Vocabulary.new("http://purl.org/ontology/po/")  # => The programme ontology
    @tl = Vocabulary.new("http://purl.org/NET/c4dm/timeline.owl#")  # => External vocabularies
    @self = "http://example.com/rdf/"     # => The prefix for self created URIs
    @xml = xml
  end
  
  # -------------------------------------------------------------------
  def parseFromFile

    info "Creating statements for Services..."
    
    @statements = Array.new
    
    # Iterate over services
    @xml.root.each_element("//ServiceInformation") do |service_info|
      @statements += parseServiceInformation(service_info)
    end
    
    info "Creating statements for Programmes..."
    
    # Iterate over programs
    @xml.root.each_element("//ProgramInformation") do |program_information|
      @statements += parseProgramInformation(program_information)
    end
    
    info "Creating statements for Schedule..."
    
    # Iterate over schedule
    @xml.root.each_element("//Schedule") do |schedule|
      @statements += parseScheduleInformation(schedule)
    end
    
    info "Total statements: #{@statements.size}"
    
  end
  
  # -------------------------------------------------------------------
  def parseServiceInformation(service_info)
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
  def parseProgramInformation(program_information)
    statements = Array.new
    
    attr_crid = program_information.attributes["programId"]
    attr_title = program_information.elements['BasicDescription/Title'].text rescue "No Title"
    attr_synopsis = program_information.elements['BasicDescription/Synopsis'].text rescue "No Synopsis"
    
    program = RDF::URI.new(attr_crid)
    
    # A program is essentially an Episode (no further details here)
    statements.push Statement.new :subject => program, :predicate => RDF.type, :object => @po.Episode
    
    # TODO do something with title and synopsis
    statements.push Statement.new :subject => program, :predicate => DC.title, :object => RDF::Literal.new(attr_title)
    statements.push Statement.new :subject => program, :predicate => @po.synopsis, :object => RDF::Literal.new(attr_synopsis)
    
    statements
  end
  
  # ----------------------------------------------------------------------
  def parseScheduleInformation(schedule) 
    statements = Array.new
    
    attr_crid = schedule.elements['ScheduleEvent'].elements['Program'].attributes['crid']
    attr_service = schedule.attributes['serviceIDRef']

    program = RDF::URI.new(attr_crid)
    serv = RDF::URI.new(@self + attr_service)

    # A program is bound to one service
    statements.push Statement.new :subject => program, :predicate => @po.service, :object => serv

    # TODO Create Version and Broadcast
    version = Node.uuid()
    broadcast = Node.uuid()

    # A program is broadcast as a broadcast certain service
    statements.push Statement.new :subject => version, :predicate => @po.broadcast, :object => broadcast
    statements.push Statement.new :subject => broadcast, :predicate => @po.broadcast_on, :object => serv

    # Create the timeline
    interval = Node.uuid()
    statements.push Statement.new :subject => interval, :predicate => RDF.type, :object => @tl.interval
    # TODO extend the timeline

    # Hook the version to the timeline
    statements.push Statement.new :subject => version, :predicate => @po.time, :object => interval
    
    statements
  end
  
  def serializeToFile(file)
    RDF::Writer.open(file) do |writer|
      writer << RDF::Graph.new do |graph|
        @statements.each do |statement|
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