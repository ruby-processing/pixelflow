project 'pixelflow' do

  model_version '4.0.0'
  id 'ruby-processing:pixelflow:1.0.0'
  packaging 'jar'

  description 'toxiclibs-library for JRubyArt'

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

  jar 'args4j:args4j:2.0.31'
  jar 'org.processing:core:3.3.5'
  jar('org.jogamp.jogl:jogl-all:${jogl.version}')
  jar('org.jogamp.gluegen:gluegen-rt-main:${jogl.version}')

  plugin( :compiler, '3.5.1',
          'source' =>  '1.8',
          'target' =>  '1.8' )
  plugin( :jar, '3.0.2',
          'archive' => {
            'manifestFile' =>  'MANIFEST.MF'
          } )
  plugin :resources, '2.6'
  
  build do
    default_goal 'package'
    source_directory 'src'
    final_name 'PixelFlow'
  end
end
