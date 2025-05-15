#
# Be sure to run `pod lib lint XZMocoa.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZMocoa'
  s.version          = '10.5.0'
  s.summary          = '一款用于 MVVM 设计模式进行 iOS 开发的基础库'

  s.description      = <<-DESC
  基于 Apple 原生 API 风格设计，简洁易学零成本上手；零监听、轻量级设计，可与 MVC 混合使用，高性能零成本接入。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = 'https://github.com/Xezun/XZKit/blob/main/Docs/#{s.name}/README.md'
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '13.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZKit/Code/{ObjC,Swift}/XZMocoa/**/*.{h,m,swift}'
    ss.project_header_files = 'XZKit/Code/ObjC/XZMocoa/**/Private/*.h'
    
    ss.dependency 'XZDefines/XZMacros'
    ss.dependency 'XZDefines/XZRuntime'
    ss.dependency 'XZExtensions/NSArray'
    ss.dependency 'XZExtensions/NSIndexSet'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.dependency '#{s.name}/Code'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
end

