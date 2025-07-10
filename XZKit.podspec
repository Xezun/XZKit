#
# Be sure to run `pod lib lint XZKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZKit'
  s.version          = '1.0.0'
  s.summary          = '一款高效、轻量、强大的 iOS 开发库'
  s.description      = <<-DESC
  一款包含 iOS 开发中常用开发组件、高频方法拓展、高性能工具类的开发库，采用了组件最小化设计原则，可以按需最小化引用。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '6.0'
  s.ios.deployment_target = '13.0'
  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1',
    'OTHER_SWIFT_FLAGS' => '-D XZ_FRAMEWORK'
  }
  
  # s.default_subspec = 'Code'
  
  s.subspec "Core" do |ss|
    ss.public_header_files = 'XZKit/Code/ObjC/XZKit.h'
    ss.source_files        = 'XZKit/Code/ObjC/XZKit.h'
  end

  def s.defineSubspec(name, languages, hasPrivates, dependencies, hasMacros)
    self.subspec name do |ss|
      # 源代码
      case languages
      when "ObjC"
        ss.public_header_files  = "XZKit/Code/ObjC/#{name}/**/*.h";
        ss.source_files         = "XZKit/Code/ObjC/#{name}/**/*.{h,m}";
      when "Swift"
        ss.source_files         = "XZKit/Code/Swift/#{name}/**/*.swift";
      when "Mixed"
        ss.public_header_files  = "XZKit/Code/ObjC/#{name}/**/*.h";
        ss.source_files         = "XZKit/Code/{ObjC,Swift}/#{name}/**/*.{h,m,swift}";
      end
      # 私有文件
      if hasPrivates
        ss.project_header_files = "XZKit/Code/Objc/#{name}/**/Private/**/*.h"
      end
      if hasMacros
        ss.preserve_paths = ["XZKit/Products/Macro/#{name}"]
        ss.pod_target_xcconfig = {
          'OTHER_SWIFT_FLAGS' => "-load-plugin-executable ${PODS_ROOT}/#{name}/XZKit/Products/Macro/#{name}Macros\##{name}Macros"
        }
        ss.user_target_xcconfig = {
          'OTHER_SWIFT_FLAGS' => "-load-plugin-executable ${PODS_ROOT}/#{name}/XZKit/Products/Macro/#{name}Macros\##{name}Macros"
        }
      end
      # 依赖
      ss.dependency "XZKit/Core"
      for dependency in dependencies
        ss.dependency "XZKit/#{dependency}";
      end
    end
  end

  # 基础
  s.defineSubspec "XZLog",        "Mixed", false, [], true
  s.defineSubspec "XZDefines",    "ObjC",  false, ["XZLog"], false
  s.defineSubspec "XZExtensions", "Mixed", false, ["XZDefines"], false
  
  # 拓展
  s.defineSubspec "XZURLQuery",       "ObjC",  false, [], false
  s.defineSubspec "XZGeometry",       "Mixed", false, [], false
  s.defineSubspec "XZContentStatus",  "Swift", false, ["XZTextImageView"], false
  s.defineSubspec "XZImage",          "ObjC",  true,  ["XZLog", "XZGeometry"], false
  s.defineSubspec "XZObjcDescriptor", "ObjC",  false, ["XZDefines"], false
  
  # 核心
  s.defineSubspec "XZML",      "ObjC",  true, ["XZDefines", "XZExtensions"], false
  s.defineSubspec "XZMocoa",   "Mixed", true, ["XZDefines", "XZExtensions", "XZObjcDescriptor"], true
  s.defineSubspec "XZToast",   "Mixed", true, ["XZGeometry", "XZTextImageView", "XZExtensions"], false
  s.defineSubspec "XZRefresh", "ObjC",  true, ["XZDefines"], false
  
  # 自定义组件
  s.defineSubspec "XZPageView",                 "ObjC",  true,  ["XZDefines", "XZGeometry", "XZExtensions"], false
  s.defineSubspec "XZProgressView",             "Swift", false, [], false
  s.defineSubspec "XZPageControl",              "ObjC",  false, ["XZExtensions"], false
  s.defineSubspec "XZSegmentedControl",         "ObjC",  true,  ["XZDefines"], false
  s.defineSubspec "XZTextImageView",            "Swift", false, ["XZGeometry"], false
  s.defineSubspec "XZNavigationController",     "Swift", false, ["XZDefines"], false
  s.defineSubspec "XZCollectionViewFlowLayout", "Swift", false, [], false
  
  # 工具类
  s.defineSubspec "XZTicker",         "Swift", false, [], false
  s.defineSubspec "XZJSON",           "ObjC",  true,  ["XZObjcDescriptor", "XZExtensions"], false
  s.defineSubspec "XZLocale",         "ObjC",  false, ["XZDefines"], false
  s.defineSubspec "XZDataCryptor",    "ObjC",  false, ["XZDefines"], false
  s.defineSubspec "XZDataDigester",   "ObjC",  false, ["XZDefines", "XZExtensions"], false
  s.defineSubspec "XZKeychain",       "ObjC",  false, ["XZLog"], false
  
end

