project 'pixelflow' do

  model_version '4.0.0'
  id 'ruby-processing:pixelflow:1.1.3'
  packaging 'jar'

  description 'PixelFlow-library for JRubyArt'

  organization 'ruby-processing', 'https://ruby-processing.github.io'

  { 'diwi' => 'Thomas Diewald', 'monkstone' => 'Martin Prout' }.each do |key, value|
    developer key do
      name value
      roles 'developer'
    end
  end

  license 'MIT', 'https://mit-license.org/'

  issue_management 'https://github.com/ruby-processing/pixelflow/issues', 'Github'

  source_control( :url => 'https://github.com/ruby-processing/pixelflow',
                  :connection => 'scm:git:git://github.com/ruby-processing/pixelflow.git',
                  :developer_connection => 'scm:git:git@github.com:ruby-processing/pixelflow.git' )

  properties( 'maven.compiler.source' => '1.8',
              'project.build.sourceEncoding' => 'UTF-8',
              'maven.compiler.target' => '1.8',
              'polyglot.dump.pom' => 'pom.xml',
              'jogl.version' => '2.3.2'
            )

  jar 'org.processing:core:3.3.6'
  jar('org.jogamp.jogl:jogl-all:${jogl.version}')
  jar('org.jogamp.gluegen:gluegen-rt-main:${jogl.version}')

  plugin( :compiler, '3.5.1',
          'source' =>  '${maven.compiler.source}',
          'target' =>  '${maven.compiler.target}' )
  plugin( :jar, '3.0.2',
          'archive' => {
            'manifestFile' =>  'MANIFEST.MF'
          } )
  plugin( :resources, '2.6')

  build do
    default_goal 'package'
    resource do
      directory 'src'
      excludes '**/*.java'
    end
    source_directory 'src'
    final_name 'PixelFlow'
  end
end
