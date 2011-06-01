## Synopsis

This is a Ruby Gem that converts [TV Anytime XML](http://www.tv-anytime.org/) data into RDF data as defined in the [BBC Programme Ontology](http://www.bbc.co.uk/ontologies/programmes/2009-09-07.shtml).

## Installation

Prerequisites: You need at least Ruby installed on your system. 

For a permanent installation, you need Ruby Gems. If you have it, run

    gem build TvaToRdf.gemspec
    gem install TvaToRdf-0.1.gem
    
Running without installation is also possible. `cd` to the directory where you downloaded this gem and then run the following for the demo data:

    ruby -I lib/ bin/TvaToRdf -i data/tva-robitza.xml -o data/output.n3

## Usage

Run the program from anywhere with:

    TvaToRdf [options]
        
Mandatory options:

 -    `-i`, `--input <input-file>`: Load from this file
 -    `-o`, `--output <output-file>`: Output to this file

Non-mandatory options:

 -    `-f`, `--filmlist <filmlist-file>`: Use this RDF file of films to match against

Common options:

 -   `-v`, `--verbose`: Verbose (debug) mode
 -   `-h`, `--help`: Show this message
 
## Removal
 
Just run

    gem uninstall TvaToRdf