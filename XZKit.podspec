#
# Be sure to run `pod lib lint XZDefines.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#



Pod::Spec.new do |s|
  s.name             = 'XZKit'
  s.version          = '10.0.0'
  s.summary          = 'XZKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       XZKit三方拓展组件
                       DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  # s.default_subspec = 'Code'
  
#  s.subspec 'XZDefines' do |ss|
#    ss.public_header_files = 'XZKit/Code/XZDefines/**/*.h'
#    ss.source_files        = 'XZKit/Code/XZDefines/**/*.{h,m}'
#  end
  
  # s.subspec 'DEBUG' do |ss|
  #   ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  # end
  
  # s.resource_bundles = {
  #   'XZDefines' => ['XZDefines/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  def s.defineSubspec(name, subspecs, dependencies)
    self.subspec name do |ss|
      # 遍历三级模块
      subspecs.each do |subspec, dependencies|
        # 三级模块定义
        ss.subspec subspec do |sss|
          sss.public_header_files = "XZKit/Code/#{name}/#{subspec}/**/*.h";
          sss.source_files        = "XZKit/Code/#{name}/#{subspec}/**/*.{h,m}";
          # 三级模块依赖
          for dependency in dependencies
            sss.dependency dependency;
          end
        end
      end
      # 二级模块依赖
      for dependency in dependencies
        ss.dependency dependency;
      end
    end
  end
  
  s.defineSubspec 'XZDefines', {
    'XZEmpty' => ['XZKit/XZDefines/XZMacro'],
    'XZDefer' => ['XZKit/XZDefines/XZMacro'],
    'XZMacro' => [],
    'XZRuntime' => [],
    'XZUtils' => []
  }, []


end

