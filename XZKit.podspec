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
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/README.md"

  s.swift_version = '6.0'
  s.ios.deployment_target = '13.0'
  
  s.preserve_paths = ["Products"]
  s.pod_target_xcconfig = {
    # 注入 OC 编译变量
    'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1',
    # 注入 Swift 编译变量
    'OTHER_SWIFT_FLAGS' => "-D XZ_FRAMEWORK",
    # 引入宏
    'OTHER_SWIFT_FLAGS[config=Debug]' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-debug#XZKitMacros',
    'OTHER_SWIFT_FLAGS[config=Release]' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-release#XZKitMacros'
  }

  # 在宿主项目中注入 Swift 宏插件
  # 无法单独为每一个子库导入宏插件，因为 CocoaPods 支持为子库设置不同 OTHER_SWIFT_FLAGS[config=Debug] 值（不带 [config=Debug] 的话支持）。
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS[config=Debug]' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-debug#XZKitMacros',
    'OTHER_SWIFT_FLAGS[config=Release]' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-release#XZKitMacros'
  }

  # s.default_subspec = 'Code'
  
  # 公共头文件。
  # 仅包含 XZKit.h 头文件，因为在 Xcode 自动生成的 XZKit-Swift.h 文件中，会引用到此头文件，
  # 而 CocoasPods 默认生成的是 XZKit-umbrella.h 文件，缺少 XZKit-Swift.h 会导致无法通过编译。
  s.subspec "Core" do |ss|
    ss.public_header_files = 'Sources/Code/ObjC/XZKit.h'
    ss.source_files        = 'Sources/Code/ObjC/XZKit.h'
  end
  
  # 拓展一个定义子库的方法
  # name: 子库名称
  # type: 子库使用的类型 ObjC、Swift、Mixed、Macro(暂不支持)
  # hasPrivates: 是否有 Private 目录
  # dependencies: 数组，当前子库依赖的其它子库
  def s.defineSubspec(name, type, hasPrivates, dependencies)
    self.subspec name do |ss|
      # 源代码
      case type
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
  s.defineSubspec "XZLog",                      "Mixed", false, []
  s.defineSubspec "XZDefines",                  "ObjC",  false, ["XZLog"]
  s.defineSubspec "XZExtensions",               "Mixed", false, ["XZDefines"]
  
  # 拓展
  s.defineSubspec "XZURLQuery",                 "ObjC",  false, []
  s.defineSubspec "XZGeometry",                 "Mixed", false, []
  s.defineSubspec "XZContentStatus",            "Swift", false, ["XZTextImageView"]
  s.defineSubspec "XZImage",                    "ObjC",  true,  ["XZLog", "XZGeometry"]
  s.defineSubspec "XZRuntime",                  "ObjC",  false, ["XZDefines"]
  
  # 核心
  s.defineSubspec "XZML",                       "Mixed", true, ["XZDefines", "XZExtensions"]
  s.defineSubspec "XZMocoa",                    "Mixed", true, ["XZDefines", "XZExtensions", "XZRuntime"]
  s.defineSubspec "XZToast",                    "Mixed", true, ["XZGeometry", "XZTextImageView", "XZExtensions"]
  s.defineSubspec "XZRefresh",                  "ObjC",  true, ["XZDefines"]
  
  # 自定义组件
  s.defineSubspec "XZPageView",                 "ObjC",  true,  ["XZDefines", "XZGeometry", "XZExtensions"]
  s.defineSubspec "XZProgressView",             "Swift", false, []
  s.defineSubspec "XZPageControl",              "ObjC",  false, ["XZExtensions"]
  s.defineSubspec "XZSegmentedControl",         "ObjC",  true,  ["XZDefines"]
  s.defineSubspec "XZTextImageView",            "Swift", false, ["XZGeometry"]
  s.defineSubspec "XZNavigationController",     "Swift", false, ["XZDefines"]
  s.defineSubspec "XZCollectionViewFlowLayout", "Swift", false, []
  
  # 工具类
  s.defineSubspec "XZTicker",                   "Swift", false, []
  s.defineSubspec "XZJSON",                     "ObjC",  true,  ["XZRuntime", "XZExtensions"]
  s.defineSubspec "XZLocale",                   "ObjC",  false, ["XZDefines", "XZExtensions"]
  s.defineSubspec "XZDataCryptor",              "ObjC",  false, ["XZDefines"]
  s.defineSubspec "XZDataDigester",             "ObjC",  false, ["XZDefines", "XZExtensions"]
  s.defineSubspec "XZKeychain",                 "ObjC",  false, ["XZLog"]
  
end

