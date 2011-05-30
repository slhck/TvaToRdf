Gem::Specification.new do |s| 
  s.name	= "TvaToRdf" 
  s.summary	= "A TVA XML to RDF generator" 
  s.version = "0.1"
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.md')) 
  s.author = "Werner Robitza"
  s.email = "werner.robitza@univie.ac.at"
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9' 
  s.files	= Dir['**/**'] 
  s.executables = [ 'TvaToRdf' ] 
  s.has_rdoc	= false
end