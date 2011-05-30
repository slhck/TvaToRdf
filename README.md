## Synopsis

This is a Ruby Gem that converts [TV Anytime XML](http://www.tv-anytime.org/) data into RDF data as defined in the [BBC Programme Ontology](http://www.bbc.co.uk/ontologies/programmes/2009-09-07.shtml).

## Installation

Prerequisites: You need Ruby and Ruby Gems installed on your system. 

If you have all that, download this repository and run

    gem build TvaToRdf.gemspec
    gem install TvaToRdf-0.1.gem

If the version changed (which I don't believe will happen all to soon), run `install`

## Usage

Run the program with:

    TvaToRdf [options]
        
Mandatory options:

 -    `-i`, `--input <input-file>`: Load from this file
 -    `-o`, `--output <output-file>`: Output to this file

Common options:

 -   `-v`, `--verbose`: Verbose (debug) mode
 -   `-h`, `--help`: Show this message