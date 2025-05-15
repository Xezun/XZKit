#
# Be sure to run `pod lib lint XZPageView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZPageView'
  s.version          = '10.8.0'
  s.summary          = 'XZPageView 是一款高效的分页视图管理组件'

  s.description      = <<-DESC
  组件 XZPageView 支持使用自定义视图，支持自动轮播、循环轮播、垂直和水平翻页。
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
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.default_subspec = 'Code'
  s.dependency 'XZDefines/XZMacros'
  s.dependency 'XZDefines/XZRuntime'
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZKit/Code/ObjC/XZPageView/**/*.{h,m}'
    ss.project_header_files = 'XZKit/Code/ObjC/XZPageView/**/Private/*.h'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.dependency "#{s.name}/Code"
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
end

