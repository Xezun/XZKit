#
# Be sure to run `pod lib lint XZNavigationController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#



Pod::Spec.new do |s|
  s.name             = 'XZNavigationController'
  s.version          = '10.5.0'
  s.summary          = '一个支持全屏手势导航、自定义导航栏的组件'

  s.description      = <<-DESC
  本组件拓展了原生 UINavigationController 的功能，使其支持自定义导航条、全屏手势导航，使用简单、接入成本为零。
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
  s.pod_target_xcconfig   = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.source_files        = 'XZKit/Code/Swift/XZNavigationController/**/*.{h,m,swift}'
    ss.dependency 'XZDefines'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
end

