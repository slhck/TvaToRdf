require 'optparse'
require 'ostruct'
  
# Some options that can be passed when the script is run from the commandline
class Options
  
  # Just initialize the OptionParser and try to parse the arguments
  def initialize(args)
    parse(args)
  end
  
  private
  
    # Parse the arguments that were passed
    def parse(args)
      OptionParser.new do |opts|
        opts.banner = '''
Welcome to MMS2 Assignment 3 RDF Creator!
Usage: ass3_task1 [options]
        '''
        opts.separator "Mandatory options:"
        
        opts.on("-i", "--input <input-file>", "Load from this file") do |file|
          $input = file
        end
        
        opts.on("-o", "--output <output-file>", "Output to this file") do |file|
          $output = file
        end        
        
        opts.separator "Common options:"
        
        opts.on_tail("-v", "--verbose", "Verbose (debug) mode") do
          $verbose = true
        end
        
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        
        begin
          args = ["-h"] if args.empty?
          opts.parse!(args)
          
          # Make some default assumptions
          @output = "output" if @output.nil?
          
        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n", opts
          exit(-1)
        end
        
      end # opts
    end # self.parse
end # Class options