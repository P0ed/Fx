# Be sure to run `pod lib lint Fx.podspec'

Pod::Spec.new do |s|
  s.name             = 'Fx'
  s.version          = '0.7'
  s.summary          = 'This is a Swift framework providing a number of functions and types that I miss in Swift standard library.'
  #s.description      = ''

  s.homepage         = 'https://github.com/P0ed/Fx'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Konstantin Sukharev' => 'poed@me.com' }
  s.source           = { :git => 'https://github.com/P0ed/Fx.git', :tag => s.version.to_s }

  s.compiler_flags = '-whole-module-optimization'
  s.ios.deployment_target = '8.0'
  s.source_files = 'Source/*'

  # s.dependency 'Runes', :git => 'https://github.com/thoughtbot/Runes', :branch => 'master'
end
