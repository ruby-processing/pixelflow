if RUBY_PLATFORM == 'java'
  require 'PixelFlow.jar'

  def import_class_list(list, string)
    list.each { |klass| java_import format(string, klass) }
  end

  BASE = 'com.thomasdiewald.pixelflow.java.%s'

  AABASE = 'com.thomasdiewald.pixelflow.java.antialiasing.%s'
  GEOMBASE = 'com.thomasdiewald.pixelflow.java.geometry.%s'

  GEOMETRY = %w[DwCube DwMeshUtils]
  ANTIALIAS = %w[FXAA.FXAA GBAA.GBAA SMAA.SMAA]
  module Antialiasing
    import_class_list(ANTIALIAS, AABASE)
  end

  module Geometry
    import_class_list(GEOMETRY, GEOMBASE)
  end

  module ImageProcessing
    include_package 'com.thomasdiewald.pixelflow.java.imageprocessing'
  end

  module Filters
    include_package 'com.thomasdiewald.pixelflow.java.imageprocessing.filter'
    java_import 'com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter'
  end

  module Render
    include_package 'com.thomasdiewald.pixelflow.java.render.skylight'
    java_import 'com.thomasdiewald.pixelflow.java.render.skylight.DwSceneDisplay'
  end

  module DwGL
    include_package  = 'com.thomasdiewald.pixelflow.java.dwgl'
    java_import 'com.thomasdiewald.pixelflow.java.utils.DwGLTextureUtils'
  end

  module PixelFlowUtils
    include_package 'com.thomasdiewald.pixelflow.java.utils'
    java_import 'com.thomasdiewald.pixelflow.java.utils.DwMagnifier'
  end

  CLASSES = %w[DwPixelFlow imageprocessing.DwShadertoy fluid.DwFluid2D]

  import_class_list(CLASSES, BASE)
end
