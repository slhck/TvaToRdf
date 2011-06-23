## Synopsis

This is a Ruby Gem that converts [TV Anytime XML](http://www.tv-anytime.org/) data into RDF data as defined in the [BBC Programme Ontology](http://www.bbc.co.uk/ontologies/programmes/2009-09-07.shtml).

It is available online under [github.com/slhck/TvaToRdf](https://github.com/slhck/TvaToRdf).

## Installation

Prerequisites: You need at least Ruby installed on your system. I'd recommend Ruby 1.9.2, others are untested. For a permanent installation, you need Ruby Gems. If you have it, run

    gem build TvaToRdf.gemspec
    gem install TvaToRdf-<version>.gem
    
where `<version>` is the current version number.

Running without installation is also possible. `cd` to the directory where you downloaded this gem and then run the following for the demo data:

    ruby -I lib/ bin/TvaToRdf -i data/tva-robitza.xml -o data/output.n3

## Basic usage

Run the program with

    TvaToRdf [options]
        
Mandatory options:

 -    `-i`, `--input <input-file>`: Load from this file
 -    `-o`, `--output <output-file>`: Output to this file

Non-mandatory options:

 -    `-f`, `--filmlist <filmlist-file>`: Use this RDF file of films to match against

Common options:

 -   `-v`, `--verbose`: Verbose (debug) mode
 -   `-h`, `--help`: Show the usage message
 
## Usage for assignment tasks 1 and 3:

For the basic assignment (Task 1), there are two run options. The first one just creates the RDF graph in N3 notation. If you want more detailed output, just append `-v`.

    TvaToRdf -i data/tva-robitza.xml -o data/output.n3
    
The second one (for Task 3) is a bit slower, because all records have to be matched against the Linked Movie Database. Therefore we use a smaller subset of programs. In the current dataset, there should be one match.

    TvaToRdf -i data/tva-robitza-short.xml -o data/output-linked.n3 -f data/film.rdf

## Removal
 
Just run

    gem uninstall TvaToRdf
    
if you've installed the Gem before. Otherwise, just delete this folder.