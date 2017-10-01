# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pixelflow/version'

Gem::Specification.new do |spec|
  spec.name = 'pixelflow'
  spec.version = PixelFlow::VERSION
  spec.has_rdoc = true
  spec.extra_rdoc_files = %w(README.md LICENSE.md)
  spec.summary = %q(PixelFlow library for JRubyArt and propane)
  spec.description =<<-EOS
  PixelFlow java library wrapped in a rubygem. Compiled and tested with JRubyArt-1.4.1 and processing-3.3.5
  EOS
  spec.license = 'MIT'
  spec.authors = %w(Thomas\ Diewald Martin\ Prout)
  spec.email = 'mamba2928@yahoo.co.uk'
  spec.homepage = 'http://ruby-processing.github.io/pixelflow/'
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files << 'lib/PixelFlow.jar'
  spec.require_paths = ['lib']
  spec.add_development_dependency 'rake', '~> 12.0', '>= 12.0.0'
  spec.platform = 'java'
end
