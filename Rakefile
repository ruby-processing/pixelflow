# frozen_string_literal: false
require_relative 'lib/pixelflow/version'

def create_manifest
  title = 'Implementation-Title: rpextras (java extension for propane)'
  version = format('Implementation-Version: %s', PixelFlow::VERSION)
  File.open('MANIFEST.MF', 'w') do |f|
    f.puts(title)
    f.puts(version)
    f.puts('Class-Path: gluegen-rt-2.3.2.jar jog-all-2.3.2.jar')
  end
end

task default: [:init, :compile, :install, :gem]

desc 'Create Manifest'
task :init do
  create_manifest
end

desc 'Install'
task :install do
  sh 'mvn dependency:copy'
  sh 'mv target/PixelFlow.jar lib'
end

desc 'Gem'
task :gem do
  sh 'gem build pixelflow.gemspec'
end

desc 'Document'
task :javadoc do
  sh 'mvn javadoc:javadoc'
end

desc 'Compile'
task :compile do
  sh 'mvn package'
end

desc 'clean'
task :clean do
  Dir['./**/*.%w{jar gem}'].each do |path|
    puts 'Deleting #{path} ...'
    File.delete(path)
  end
  FileUtils.rm_rf('./target')
end
