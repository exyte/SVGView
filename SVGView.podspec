Pod::Spec.new do |s|
  s.name             = "SVGView"
  s.version          = "1.0.4"
  s.summary          = "SVGParser created with SwiftUI."

  s.homepage         = 'https://github.com/exyte/SVGView.git'
  s.license          = 'MIT'
  s.author           = { 'exyte' => 'info@exyte.com' }
  s.source           = { :git => 'https://github.com/izi-team/SVGView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://exyte.com'

  s.platform = :ios
  s.platform = :osx

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '11.0'
  
  s.requires_arc     = true
  s.swift_version    = '5.5'

  s.source_files = [
     'Source/**/*.h',
     'Source/**/*.swift'
  ]
end
