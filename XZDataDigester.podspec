#
# Be sure to run `pod lib lint XZDataDigester.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#



Pod::Spec.new do |s|
  s.name             = 'XZDataDigester'
  s.version          = '10.1.0'
  s.summary          = '对原生框架 CommonDigest 的封装，提高开发效率。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  XZDataDigester 对 CommonDigest 进行了封装，提供了面向对象的接口，使用更顺手，提高开发效率。
                       DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZKit/Code/XZDataDigester/**/*.{h,m}'
    ss.dependency 'XZExtensions/NSData'
    ss.dependency 'XZDefines/XZDefer'
  end
  
 
  # s.resource_bundles = {
  #   'XZDataDigester' => ['XZDataDigester/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  
  # def s.defineSubspec(name, dependencies)
  #   self.subspec name do |ss|
  #     ss.public_header_files = "XZDataDigester/Code/#{name}/**/*.h";
  #     ss.source_files        = "XZDataDigester/Code/#{name}/**/*.{h,m}";
  #     for dependency in dependencies
  #       ss.dependency dependency;
  #     end
  #   end
  # end
  
  # s.defineSubspec 'CAAnimation',        [];

end

