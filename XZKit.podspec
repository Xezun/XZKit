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
  
  s.preserve_paths = ["Products/XZKitMacros-{debug,release}"]
  s.pod_target_xcconfig = {
    # 注入 OC 编译变量
    'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1',
    # 注入 Swift 编译变量
    'OTHER_SWIFT_FLAGS' => "-D XZ_FRAMEWORK",
    # 引入宏
    'OTHER_SWIFT_FLAGS[config=Debug]' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-debug#XZKitMacros',
    'OTHER_SWIFT_FLAGS[config=Release]' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-release#XZKitMacros'
  }

  # 在宿主项目中注入宏
  # 无法单独为每一个子库导入宏，因为所有子库 OTHER_SWIFT_FLAGS 的值需要保持一致，否则无法导入
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS[config=Debug]' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-debug#XZKitMacros',
    'OTHER_SWIFT_FLAGS[config=Release]' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-debug#XZKitMacros'
  }

  # s.default_subspec = 'Code'
  
  s.subspec "Core" do |ss|
    ss.public_header_files = 'Sources/Code/ObjC/XZKit.h'
    ss.source_files        = 'Sources/Code/ObjC/XZKit.h'
  end
  
  D_FLAGS = [];
  R_FLAGS = [];

  def s.defineSubspec(name, languages, hasPrivates, dependencies, macrosType)
    self.subspec name do |ss|
      # 源代码
      case languages
      when "ObjC"
        ss.public_header_files  = "Sources/Code/ObjC/#{name}/**/*.h";
        ss.source_files         = "Sources/Code/ObjC/#{name}/**/*.{h,m}";
      when "Swift"
        ss.source_files         = "Sources/Code/Swift/#{name}/**/*.swift";
      when "Mixed"
        ss.public_header_files  = "Sources/Code/ObjC/#{name}/**/*.h";
        ss.source_files         = "Sources/Code/{ObjC,Swift}/#{name}/**/*.{h,m,swift}";
      end
      
      # 私有文件
      if hasPrivates
        ss.project_header_files = "Sources/Code/Objc/#{name}/**/Private/**/*.h"
      end

      # 依赖
      ss.dependency "XZKit/Core"
      for dependency in dependencies
        ss.dependency "XZKit/#{dependency}";
      end
    end
  end

  # 基础
  s.defineSubspec "XZLog",        "Mixed", false, [], 2
  s.defineSubspec "XZDefines",    "ObjC",  false, ["XZLog"], 0
  s.defineSubspec "XZExtensions", "Mixed", false, ["XZDefines"], 0
  
  # 拓展
  s.defineSubspec "XZURLQuery",       "ObjC",  false, [], 0
  s.defineSubspec "XZGeometry",       "Mixed", false, [], 0
  s.defineSubspec "XZContentStatus",  "Swift", false, ["XZTextImageView"], 0
  s.defineSubspec "XZImage",          "ObjC",  true,  ["XZLog", "XZGeometry"], 0
  s.defineSubspec "XZObjcDescriptor", "ObjC",  false, ["XZDefines"], 0
  
  # 核心
  s.defineSubspec "XZML",      "ObjC",  true, ["XZDefines", "XZExtensions"], 0
  s.defineSubspec "XZMocoa",   "Mixed", true, ["XZDefines", "XZExtensions", "XZObjcDescriptor"], 1
  s.defineSubspec "XZToast",   "Mixed", true, ["XZGeometry", "XZTextImageView", "XZExtensions"], 0
  s.defineSubspec "XZRefresh", "ObjC",  true, ["XZDefines"], 0
  
  # 自定义组件
  s.defineSubspec "XZPageView",                 "ObjC",  true,  ["XZDefines", "XZGeometry", "XZExtensions"], 0
  s.defineSubspec "XZProgressView",             "Swift", false, [], 0
  s.defineSubspec "XZPageControl",              "ObjC",  false, ["XZExtensions"], 0
  s.defineSubspec "XZSegmentedControl",         "ObjC",  true,  ["XZDefines"], 0
  s.defineSubspec "XZTextImageView",            "Swift", false, ["XZGeometry"], 0
  s.defineSubspec "XZNavigationController",     "Swift", false, ["XZDefines"], 0
  s.defineSubspec "XZCollectionViewFlowLayout", "Swift", false, [], 0
  
  # 工具类
  s.defineSubspec "XZTicker",         "Swift", false, [], 0
  s.defineSubspec "XZJSON",           "ObjC",  true,  ["XZObjcDescriptor", "XZExtensions"], 0
  s.defineSubspec "XZLocale",         "ObjC",  false, ["XZDefines"], 0
  s.defineSubspec "XZDataCryptor",    "ObjC",  false, ["XZDefines"], 0
  s.defineSubspec "XZDataDigester",   "ObjC",  false, ["XZDefines", "XZExtensions"], 0
  s.defineSubspec "XZKeychain",       "ObjC",  false, ["XZLog"], 0
  
end

