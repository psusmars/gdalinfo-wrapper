module GDALInfoWrapper
  class GDALInfo
    # The raw gdalinfo command that is split into lines, to_s will join into
    # new lines
    attr_reader :raw_gdalinfo

    # Origin point as a Point
    attr_reader :origin_point

    # Pixel related dimensions
    attr_reader :pixel_size, :width, :height

    # The various coordinate points according to the bounds
    attr_reader :upper_left, :upper_right, :lower_left, :lower_right, :center

    # The coordinate system that could be used with other gdal commands
    attr_reader :coordinate_system

    # The Metadata attributes associated with the  gdalinfo
    attr_reader :metadata

    # Gives the total number of bands.
    attr_reader :total_bands
    # bandX variables will also be set and accessible

    def initialize(image_path)
      @metadata = {}
      @bands = []
      @raw_gdalinfo = `#{GDALInfoWrapper.gdalinfo_exe} -hist #{image_path}`.split("\n")
      @total_bands = 0
      i = 0 
      while i < @raw_gdalinfo.length do
        line = @raw_gdalinfo[i]
        case line
        when /Size is/
          m = /(\d+), (\d+)/.match(line)
          @width = m[1].to_i
          @height = m[2].to_i
        when /Coordinate System is:/
          @coordinate_system = ""
          i += 1
          while !(@raw_gdalinfo[i] =~ /Origin = /) do
            @coordinate_system += @raw_gdalinfo[i]
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
          while m = Util::METADATA_REGEX.match(@raw_gdalinfo[i]) do
            @metadata[m[1]] = m[2]
            i += 1
          end
          i -= 1
        when /Corner Coordinates:/
          i += 1
          while m = /(((Upper|Lower)\s*(Left|Right))|(Center))\s*#{Util::POINT_REGEX}/.match(@raw_gdalinfo[i]) do
            instance_variable_set("@#{Util.underscore(m[1])}", Point.new(m[6].to_f, m[7].to_f))
            i += 1
          end
          i -= 1
        when /Band \d+/
          @total_bands += 1
          j = i + 1
          j += 1 while j < @raw_gdalinfo.length && !(/Band \d+/ =~ @raw_gdalinfo[j])

          # band line
          m = /(Band \d+).+?Type=(.+?),\s*ColorInterp=(\S+)/.match(line)
          band_variable_name = Util.underscore(m[1]).gsub("_", "")
          self.class.send(:attr_accessor, band_variable_name)
          band = Band.new()
          band.type = m[2]
          band.color_interp = m[3]

          # We now have our array for our band
          while i < j do
            line = @raw_gdalinfo[i]
            case line
            when /\A(\d|\s)+\Z/
                  # just buckets
                  band.buckets = @raw_gdalinfo[i].split(" ").map(&:to_i)
                when /Overviews: (.+?)/
                  band.overviews = $~[1]
                when /Metadata:/
                  i += 1 
                  while m = Util::METADATA_REGEX.match(@raw_gdalinfo[i]) do
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
      return self.raw_gdalinfo.join("\n")
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