# gdalinfo-wrapper
Used to parse gdalinfo into a friendly ruby class for clean tests and usage.

# Usage

``` ruby
require 'gdalinfo-wrapper'

# This isn't required
GDALInfo.gdalinfo_exe = "/bin/usr/gdalinfo"

ginfo = GDALInfoWrapper::GDALInfo.new("PATH/TO/SOME/FILE")

ginfo.metadata["TIFF_TAG_SOFTWARE"]

puts ginfo

```

# NOTICE

This was written, and tested, with GDAL 1.10.1, should work with any version of gdal. Don't hesitate to contribute or request additional version support.
