require 'gdalinfo-wrapper/band'
require 'gdalinfo-wrapper/point'
require 'gdalinfo-wrapper/util'
require 'gdalinfo-wrapper/gdalinfo'

module GDALInfoWrapper
  # Set this to whatever your exe location is, it's assumed the one in your path
  # will be the one you want
  @gdalinfo_exe = "gdalinfo"
  class << self
    attr_accessor :gdalinfo_exe
  end
end