#
# Be sure to run `pod lib lint XZExtensions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#



Pod::Spec.new do |s|
  s.name             = 'XZExtensions'
  s.version          = '10.8.0'
  s.summary          = '对原生框架的拓展，提高开发效率'

  s.description      = <<-DESC
  XZExtensions 包含了对原生框架的拓展，丰富了原生框架的功能，提高了开发效率。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/Docs/#{s.name}/README.md"

  s.swift_version = '5.0'
  s.ios.deployment_target = '13.0'
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
    ss.dependency 'XZDefines'
    
    ss.source_files = 'XZKit/Code/{ObjC,Swift}/XZExtensions/**/*.{h,m,swift}'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
    ss.dependency "#{s.name}/Code"
  end
  
end

