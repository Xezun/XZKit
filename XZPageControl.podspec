#
# Be sure to run `pod lib lint XZPageControl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZPageControl'
  s.version          = '10.1.0'
  s.summary          = '一款支持自由定制外观的、类似于 UIPageControl 的视图控件。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

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

  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZKit/Code/ObjC/XZPageControl/**/*.{h,m}'
    ss.project_header_files = 'XZKit/Code/ObjC/XZPageControl/**/Private/*.h'
    ss.dependency 'XZExtensions/XZShapeView'
  end
  
  # s.resource_bundles = {
  #   'XZPageControl' => ['XZPageControl/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

