require_relative 'options'
require_relative 'xmlToRdf'
require 'pp'
require 'rdf'
require 'rdf/n3'
require 'rexml/document'
require 'uuid'
include REXML
include RDF

module TvaToRdf

class Runner
  
  def initialize(args)
    Options.new(args)
  end
  
  def run
    parse_input
    write_graph
  end
  
  def parse_input
    info "Opening XML file..."
    xml = Document.new(File.open($input)) rescue "Could not open file!"
    
    # Create a new parser
    if $link
      info "Reading Film list.."
      filmlist = Document.new(File.open($filmlist)) rescue "Could not open file!"
      xmlParser = XmlToRdf.new(xml, filmlist)
    else
      xmlParser = XmlToRdf.new(xml)
    end
    
    # Parse
    xmlParser.parse_from_file
    
    info "Writing output"
    xmlParser.serialize_to_file($output)
    info "Finished processing"
  end
  
    
  def write_graph

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