#
# Be sure to run `pod lib lint XZPageControl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZPageControl'
  s.version          = '10.5.0'
  s.summary          = '一款支持自由定制外观的、类似于 UIPageControl 的视图控件。'

  s.description      = <<-DESC
  相比于原生控件 UIPageControl 而言， XZPageControl 提供了更方便的指示器样式设置方式，
  比如可以直接设置指示器的颜色、形状，或者将图片作为指示器，或者将自定义控件作为指示器，
  并且每一个指示器还支持单独设置样式。
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
    ss.source_files = 'XZKit/Code/ObjC/XZPageControl/**/*.{h,m}'
    ss.project_header_files = 'XZKit/Code/ObjC/XZPageControl/**/Private/*.h'
    ss.dependency 'XZExtensions/XZShapeView'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.dependency '#{s.name}/Code'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
end

