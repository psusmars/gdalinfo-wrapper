module GDALInfoWrapper
  class Point
    attr_accessor :x, :y
    def initialize(x, y)
      @x = x
      @y = y
    end

    def [](i)
      if i == 0 then
        return x
      else
        return y
      end
    end

    def to_a
      return [@x, @y]
    end
  end
end