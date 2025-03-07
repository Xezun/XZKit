#
# Be sure to run `pod lib lint XZDefines.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#



Pod::Spec.new do |s|
  s.name             = 'XZDefines'
  s.version          = '10.5.0'
  s.summary          = 'XZKit 的基础部分'

  s.description      = <<-DESC
  XZDefines 包含 XZKit 中常用的一些基础定义。
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
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.public_header_files = 'XZKit/Code/ObjC/XZDefines/**/*.h'
    ss.source_files        = 'XZKit/Code/ObjC/XZDefines/**/*.{h,m}'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.dependency 'XZDefines/Code'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
  def s.defineSubspec(name, dependencies)
    self.subspec name do |ss|
      ss.public_header_files = "XZKit/Code/ObjC/XZDefines/#{name}/**/*.h";
      ss.source_files        = "XZKit/Code/ObjC/XZDefines/#{name}/**/*.{h,m}";
      for dependency in dependencies
        ss.dependency dependency;
      end
    end
  end
  
  s.defineSubspec 'XZEmpty', ['XZDefines/XZMacro']
  s.defineSubspec 'XZDefer', ['XZDefines/XZMacro']
  s.defineSubspec 'XZMacro', []
  s.defineSubspec 'XZRuntime', []
  s.defineSubspec 'XZUtils', []

end

