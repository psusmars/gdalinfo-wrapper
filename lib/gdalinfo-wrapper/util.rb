module GDALInfoWrapper
  class Util
    POINT_REGEX = /\(\s*(-?\d*\.\d*)\s*,\s*(\s*-?\d*\.\d*)\)/
    METADATA_REGEX = /\A\s*(\S+?)=(\S+)\Z/
    def self.underscore(string)
      string.gsub(" ", "_").downcase
    end
  end
end