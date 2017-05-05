$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'gdalinfo-wrapper/version'

spec = Gem::Specification.new do |s|
  s.name = 'gdalinfo-wrapper'
  s.version = GDALInfoWrapper::VERSION
  s.required_ruby_version = '>= 1.9.1'
  s.summary = 'A simple wrapper class to parse the gdalinfo command into a cleanly accessible class'
  s.description = 'Written according to the gdalinfo command which can be found here: http://www.gdal.org/gdalinfo.html'
  s.author = 'Paul Susmarski'
  s.email = 'paul@susmarski.com'
  s.homepage = 'http://rubygems.org/gems/fielview'

  s.files = Dir['lib/**/*.rb']
  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end