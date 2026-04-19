#
# Be sure to run `pod lib lint XZKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZKit'
  s.version          = '1.1.0'
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

  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'
  
  s.preserve_paths = ["Products"]
  
  # 编译宏
  # 执行 pod install 前，可通过环境变量指定 Debug 和 Release 的配置。默认的 Debug 和 Release 不需要指定。
  # export DEBUG_CONFIGURATIONS="Debug,Test"
  # export RELEASE_CONFIGURATIONS="Release,Beta"
  s.prepare_command = <<-CMD
    sh "./Scripts/LinkMacros.sh" "${DEBUG_CONFIGURATIONS}" "${RELEASE_CONFIGURATIONS}";
  CMD
  
  s.pod_target_xcconfig = {
    # 注入 OC 编译变量
    'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1',
    # 注入 Swift 编译变量
    'OTHER_SWIFT_FLAGS' => "-D XZ_FRAMEWORK -load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-${CONFIGURATION}#XZKitMacros",
  }

  # 在宿主项目中注入 Swift 宏插件
  # 无法单独为每一个子库导入宏插件，因为 CocoaPods 支持为子库设置不同 OTHER_SWIFT_FLAGS[config=Debug] 值（不带 [config=Debug] 的话支持）。
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-${CONFIGURATION}#XZKitMacros',
  }

  # s.default_subspec = 'Code'
  
  # 公共头文件。
  # 仅包含 XZKit.h 头文件，因为在 Xcode 自动生成的 XZKit-Swift.h 文件中，会引用到此头文件，
  # 而 CocoasPods 默认生成的是 XZKit-umbrella.h 文件，缺少 XZKit-Swift.h 会导致无法通过编译。
  s.subspec "Core" do |ss|
    ss.public_header_files = 'Sources/ObjC/Code/XZKit.h'
    ss.source_files        = 'Sources/ObjC/Code/XZKit.h'
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
      when "objc"
        ss.public_header_files  = "Sources/ObjC/Code/#{name}/**/*.h";
        ss.source_files         = "Sources/ObjC/Code/#{name}/**/*.{h,m}";
      when "swift"
        ss.source_files         = "Sources/Swift/#{name}/**/*.swift";
      when "mixed"
        ss.public_header_files  = "Sources/ObjC/Code/#{name}/**/*.h";
        ss.source_files         = "Sources/ObjC/Code/#{name}/**/*.{h,m}", "Sources/Swift/#{name}/**/*.swift";
      end
      
      # 私有文件
      if hasPrivates
        ss.project_header_files = "Sources/Objc/Code/#{name}/**/Private/**/*.h"
      end

      # 依赖
      ss.dependency "XZKit/Core"
      for dependency in dependencies
        ss.dependency "XZKit/#{dependency}";
      end
    end
  end

  # 基础
  s.defineSubspec "XZLog",                      "mixed", false, [];
  s.defineSubspec "XZObjc",                     "objc",  false, [];
  s.defineSubspec "XZDefines",                  "objc",  false, ["XZLog"];
  s.defineSubspec "XZExtensions",               "mixed", false, ["XZDefines"];

  # 拓展
  s.defineSubspec "XZURLQuery",                 "objc",  false, [];
  s.defineSubspec "XZGeometry",                 "mixed", false, [];
  s.defineSubspec "XZContentStatus",            "swift", false, ["XZTextImageView"];
  s.defineSubspec "XZImage",                    "objc",  true,  ["XZLog", "XZGeometry"];
  
  # 核心
  s.defineSubspec "XZML",                       "mixed", true, ["XZDefines", "XZExtensions"];
  s.defineSubspec "XZMocoa",                    "mixed", true, ["XZDefines", "XZExtensions", "XZObjc"];
  s.defineSubspec "XZToast",                    "mixed", true, ["XZGeometry", "XZTextImageView", "XZExtensions"];
  s.defineSubspec "XZRefresh",                  "objc",  true, ["XZDefines"]
  
  # 自定义组件
  s.defineSubspec "XZPageView",                 "objc",  true,  ["XZDefines", "XZGeometry", "XZExtensions"];
  s.defineSubspec "XZProgressView",             "swift", false, [];
  s.defineSubspec "XZPageControl",              "objc",  false, ["XZExtensions"];
  s.defineSubspec "XZSegmentedControl",         "objc",  true,  ["XZDefines"];
  s.defineSubspec "XZTextImageView",            "swift", false, ["XZGeometry"];
  s.defineSubspec "XZNavigationController",     "swift", false, ["XZDefines"];
  s.defineSubspec "XZCollectionViewFlowLayout", "swift", false, [];
  
  # 工具类
  s.defineSubspec "XZTicker",                   "swift", false, [];
  s.defineSubspec "XZJSON",                     "objc",  true,  ["XZObjc", "XZExtensions"];
  s.defineSubspec "XZLocale",                   "objc",  false, ["XZDefines", "XZExtensions"];
  s.defineSubspec "XZDataCryptor",              "objc",  false, ["XZDefines"];
  s.defineSubspec "XZDataDigester",             "objc",  false, ["XZDefines", "XZExtensions"];
  s.defineSubspec "XZKeychain",                 "objc",  false, ["XZLog"];
  
end

