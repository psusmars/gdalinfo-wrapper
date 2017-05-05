module GDALInfoWrapper
  class Band
    attr_accessor :type, :color_interp, :buckets, :metadata, :overviews
    def initialize
      @metadata = {}
      @overviews = nil
    end

    def mostly_empty?(minimum_empty_buckets=200)
      return self.buckets.count(0) >= minimum_empty_buckets
    end

    def has_overviews?
      return !overviews.nil?
    end
  end
end