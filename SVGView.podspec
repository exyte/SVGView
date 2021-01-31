Pod::Spec.new do |s|
  s.name             = "SVGView"
  s.version          = "0.0.1"
  s.summary          = "SVGParser created with SwiftUI."

  s.homepage         = 'https://github.com/exyte/SVGView.git'
  s.license          = 'MIT'
  s.author           = { 'exyte' => 'info@exyte.com' }
  s.source           = { :git => 'https://github.com/exyte/SVGView.git', :tag => s.version.to_s }
  s.social_media_url = 'http://exyte.com'

  s.platform = :ios
  s.platform = :osx
  s.platform = :tvos
  s.platform = :watchos

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.tvos.deployment_target = '14.0'
  s.watchos.deployment_target = '7.0'
  
  s.requires_arc     = true
  s.swift_version    = '5.2'

  s.source_files = [
     'Source/**/*.h',
     'Source/**/*.swift'
  ]
end
