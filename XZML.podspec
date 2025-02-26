#
# Be sure to run `pod lib lint XZML.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZML'
  s.version          = '10.5.0'
  s.summary          = 'XZML 富文本标记语言'

  s.description      = <<-DESC
  XZML 是一款轻量级的 iOS 富文本解决方案，可以快速方便的直接通过字符串构造富文本，用于解决 iOS 开发中，构造富文本繁琐，及不能直接下发富文本的问题。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = 'https://github.com/Xezun/XZKit/blob/main/Docs/#{s.name}/README.md'

  s.swift_version = '6.0'
  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.dependency 'XZDefines/XZMacro'
  s.dependency 'XZExtensions/UIColor'
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZKit/Code/ObjC/XZML/**/*.{h,m}'
    ss.private_header_files = 'XZKit/Code/ObjC/XZML/**/Core/*.h'
  end
  
end

