module GDALInfoWrapper
  class GDALInfo

    attr_accessor :origin_point, :pixel_size, :width, :height, :upper_left, :upper_right
    attr_accessor :lower_left, :lower_right, :coordinate_system, :raw_gdal_info, :total_bands
    attr_accessor :metadata
    # bandX variables will also be set.

    def initialize(image_path)
      @metadata = {}
      @bands = []
      @raw_gdal_info = `#{GDALInfoWrapper.gdalinfo_exe} -hist #{image_path}`.split("\n")
      @total_bands = 0
      i = 0 
      while i < @raw_gdal_info.length do
        line = @raw_gdal_info[i]
        case line
        when /Size is/
          m = /(\d+), (\d+)/.match(line)
          @width = m[1].to_i
          @height = m[2].to_i
        when /Coordinate System is:/
          @coordinate_system = ""
          i += 1
          while !(@raw_gdal_info[i] =~ /Origin = /) do
            @coordinate_system += @raw_gdal_info[i]
            i += 1
          end
          i -= 1
        when /Origin = /
          m = Util::POINT_REGEX.match(line)
          @origin_point = Point.new(m[1].to_f, m[2].to_f)
        when /Pixel Size = /
          m = Util::POINT_REGEX.match(line)
          @pixel_size = Point.new(m[1].to_f, m[2].to_f)
        when /Metadata:/
          i += 1 
          while m = Util::METADATA_REGEX.match(@raw_gdal_info[i]) do
            @metadata[m[1]] = m[2]
            i += 1
          end
          i -= 1
        when /Corner Coordinates:/
          i += 1
          while m = /(((Upper|Lower)\s*(Left|Right))|(Center))\s*#{Util::POINT_REGEX}/.match(@raw_gdal_info[i]) do
            instance_variable_set("@#{Util.underscore(m[1])}", Point.new(m[6].to_f, m[7].to_f))
            i += 1
          end
          i -= 1
        when /Band \d+/
          @total_bands += 1
          j = i + 1
          j += 1 while j < @raw_gdal_info.length && !(/Band \d+/ =~ @raw_gdal_info[j])

          # band line
          m = /(Band \d+).+?Type=(.+?),\s*ColorInterp=(\S+)/.match(line)
          band_variable_name = Util.underscore(m[1]).gsub("_", "")
          self.class.send(:attr_accessor, band_variable_name)
          band = Band.new()
          band.type = m[2]
          band.color_interp = m[3]

          # We now have our array for our band
          while i < j do
            line = @raw_gdal_info[i]
            case line
            when /\A(\d|\s)+\Z/
                  # just buckets
                  band.buckets = @raw_gdal_info[i].split(" ").map(&:to_i)
                when /Overviews: (.+?)/
                  band.overviews = $~[1]
                when /Metadata:/
                  i += 1 
                  while m = Util::METADATA_REGEX.match(@raw_gdal_info[i]) do
                    band.metadata[m[1]] = m[2]
                    i += 1
                  end
                  i -= 1
                end
                i += 1
              end
              i -= 1
              instance_variable_set("@#{band_variable_name}", band)
            end
            i += 1 
          end
        end
      end
    end

    def to_s
      return self.raw_gdal_info.join("\n")
    end

    def all_bands_have_overviews?
      overviews = false
      i = 1
      while b = self.instance_variable_get("@band#{i}") do
        # We at least have bands
        overviews = true if i == 1
        overviews = overviews && b.has_overviews?
        i += 1
      end
      return overviews
    end

    def is_image_projection?(projection)
      m =  /PROJCS/.match(self.coordinate_system)
      if projection.nil? || projection.empty? then
        return !m
      else
        return !!m
      end
    end
  end
end