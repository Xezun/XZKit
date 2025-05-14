#
# Be sure to run `pod lib lint XZRefresh.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZRefresh'
  s.version          = '10.8.0'
  s.summary          = '迄今为止 iOS 最流畅的下拉刷新、上拉加载组件'

  s.description      = <<-DESC
  XZRefresh 采用了更科学的设计方式，不仅比其它下拉刷新组件更流畅，而且还支持支持拓展，方便开发者完全自定义下拉刷新的样式。
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
    ss.source_files = 'XZKit/Code/ObjC/XZRefresh/**/*.{h,m}'
    ss.project_header_files = 'XZKit/Code/ObjC/XZRefresh/**/Private/*.h'
    ss.dependency 'XZDefines/XZRuntime'
    ss.dependency 'XZDefines/XZDefer'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.dependency 'XZRefresh/Code'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
end

