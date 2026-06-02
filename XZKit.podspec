#
# Be sure to run `pod lib lint XZKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZKit'
  s.version          = '2.0.0'
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
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/README.md?raw=true"
  
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
  
  # XZKit 项目配置
  s.pod_target_xcconfig = {
    # 注入 OC 编译变量
    'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1',
    # 注入 Swift 编译变量
    'OTHER_SWIFT_FLAGS' => "-D XZ_FRAMEWORK -load-plugin-executable ${PODS_ROOT}/XZKit/Products/XZKitMacros-${CONFIGURATION}#XZKitMacros",
  }

  # 宿主项目配置
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
    ss.public_header_files = 'Sources/ObjC/XZKit.h'
    ss.source_files        = 'Sources/ObjC/XZKit.h'
  end
  
  # XZDefines
  s.subspec "XZDefines" do |ss|
    ss.subspec "Core" do |sss|
      sss.public_header_files = "Sources/ObjC/XZDefines/XZDefines.h"
      sss.source_files        = 'Sources/ObjC/XZDefines/XZDefines.h'
      sss.dependency "XZKit/Core"
    end
    
    ss.subspec "XZDefer" do |sss|
      sss.public_header_files = "Sources/ObjC/XZDefines/XZDefer/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZDefines/XZDefer/**/*.{h,m}'
      sss.dependency "XZKit/XZDefines/Core"
      sss.dependency "XZKit/XZDefines/XZMacros"
    end
    
    ss.subspec "XZEmpty" do |sss|
      sss.public_header_files = "Sources/ObjC/XZDefines/XZEmpty/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZDefines/XZEmpty/**/*.{h,m}'
      sss.dependency "XZKit/XZDefines/Core"
      sss.dependency "XZKit/XZDefines/XZMacros"
    end
    
    ss.subspec "XZMacros" do |sss|
      sss.public_header_files = "Sources/ObjC/XZDefines/XZMacros/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZDefines/XZMacros/**/*.{h,m}'
      sss.dependency "XZKit/XZDefines/Core"
    end
    
    ss.subspec "XZUtils" do |sss|
      sss.public_header_files = "Sources/ObjC/XZDefines/XZUtils/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZDefines/XZUtils/**/*.{h,m}'
      sss.dependency "XZKit/XZDefines/Core"
    end
    
    ss.subspec "XZRuntime" do |sss|
      sss.public_header_files = "Sources/ObjC/XZDefines/XZRuntime/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZDefines/XZRuntime/**/*.{h,m}'
      sss.dependency "XZKit/XZDefines/Core"
    end
  end
  
  # XZExtensions
  s.subspec "XZExtensions" do |ss|
    ss.subspec "Core" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/XZExtensions.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/XZExtensions.h'
      sss.dependency "XZKit/Core"
    end
    
    ss.subspec "CAAnimation" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/CAAnimation/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/CAAnimation/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "CALayer" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/CALayer/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/CALayer/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "NSArray" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSArray/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/NSArray/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "NSAttributedString" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSAttributedString/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/NSAttributedString/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
      sss.dependency "XZKit/XZExtensions/UIFont"
    end
    
    ss.subspec "NSBundle" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSBundle/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/NSBundle/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "NSCharacterSet" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSCharacterSet/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/NSCharacterSet/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "NSData" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSData/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/NSData/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "NSDate" do |sss|
      # sss.public_header_files = "Sources/ObjC/XZExtensions/NSDate/**/*.h"
      sss.source_files        = 'Sources/Swift/XZExtensions/NSDate/**/*.swift'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "NSDictionary" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSDictionary/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/NSDictionary/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
      sss.dependency "XZKit/XZExtensions/NSArray"
      sss.dependency "XZKit/XZExtensions/NSString"
    end
    
    ss.subspec "NSIndexSet" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSIndexSet/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/NSIndexSet/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "NSObject" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSObject/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/NSObject/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
      sss.dependency "XZKit/XZExtensions/NSArray"
      sss.dependency "XZKit/XZDefines/XZMacros"
    end
    
    ss.subspec "NSString" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/NSString/**/*.h"
      sss.source_files        = 'Sources/{ObjC,Swift}/XZExtensions/NSString/**/*.{h,m,swift}'
      sss.dependency "XZKit/XZExtensions/Core"
      sss.dependency "XZKit/XZExtensions/NSCharacterSet"
      sss.dependency "XZKit/XZExtensions/NSData"
      sss.dependency "XZKit/XZDefines/XZMacros"
    end
    
    ss.subspec "UIApplication" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/UIApplication/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/UIApplication/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "UIBezierPath" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/UIBezierPath/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/UIBezierPath/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "UIColor" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/UIColor/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/UIColor/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
      sss.dependency "XZKit/XZDefines/XZMacros"
    end
    
    ss.subspec "UIDevice" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/UIDevice/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/UIDevice/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
      sss.dependency "XZKit/XZDefines/XZDefer"
    end
    
    ss.subspec "UIFont" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/UIFont/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/UIFont/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "UIImage" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/UIImage/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/UIImage/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
      sss.dependency "XZKit/XZDefines/XZMacros"
      sss.dependency "XZKit/XZDefines/XZDefer"
    end
    
    ss.subspec "UIView" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/UIView/**/*.h"
      sss.source_files        = 'Sources/{ObjC,Swift}/XZExtensions/UIView/**/*.{h,m,swift}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
    
    ss.subspec "UIViewController" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/UIViewController/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/UIViewController/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
      sss.dependency "XZKit/XZExtensions/UIApplication"
      sss.dependency "XZKit/XZDefines/XZRuntime"
    end
    
    ss.subspec "XZShapeView" do |sss|
      sss.public_header_files = "Sources/ObjC/XZExtensions/XZShapeView/**/*.h"
      sss.source_files        = 'Sources/ObjC/XZExtensions/XZShapeView/**/*.{h,m}'
      sss.dependency "XZKit/XZExtensions/Core"
    end
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
        ss.public_header_files  = "Sources/ObjC/#{name}/**/*.h";
        ss.source_files         = "Sources/ObjC/#{name}/**/*.{h,m}";
      when "swift"
        ss.source_files         = "Sources/Swift/#{name}/**/*.swift";
      when "mixed"
        ss.public_header_files  = "Sources/ObjC/#{name}/**/*.h";
        ss.source_files         = "Sources/ObjC/#{name}/**/*.{h,m}", "Sources/Swift/#{name}/**/*.swift";
      end
      
      # 私有文件
      if hasPrivates
        ss.project_header_files = "Sources/Objc/#{name}/**/Private/**/*.h"
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

  # 拓展
  s.defineSubspec "XZURLQuery",                 "objc",  false, [];
  s.defineSubspec "XZGeometry",                 "mixed", false, [];
  s.defineSubspec "XZContentStatus",            "swift", false, ["XZTextImageView"];
  s.defineSubspec "XZImage",                    "objc",  true,  ["XZGeometry"];
  
  # 核心
  s.defineSubspec "XZML",                       "mixed", true, ["XZExtensions/UIColor"];
  s.defineSubspec "XZMocoa",                    "mixed", true, ["XZDefines/XZMacros", "XZDefines/XZRuntime", "XZExtensions/NSArray", "XZExtensions/NSIndexSet", "XZExtensions/UIView", "XZObjc"];
  s.defineSubspec "XZToast",                    "mixed", true, ["XZGeometry", "XZExtensions/UIApplication", "XZExtensions/UIView", "XZExtensions/XZShapeView"];
  s.defineSubspec "XZRefresh",                  "objc",  true, ["XZDefines/XZMacros", "XZDefines/XZRuntime"]
  
  # 自定义组件
  s.defineSubspec "XZPageView",                 "objc",  true,  ["XZDefines/XZMacros", "XZDefines/XZRuntime", "XZGeometry"];
  s.defineSubspec "XZProgressView",             "swift", false, ["XZExtensions/XZShapeView"];
  s.defineSubspec "XZPageControl",              "objc",  false, ["XZExtensions/XZShapeView"];
  s.defineSubspec "XZSegmentedControl",         "objc",  true,  ["XZDefines/XZMacros"];
  s.defineSubspec "XZTextImageView",            "swift", false, ["XZGeometry"];
  s.defineSubspec "XZNavigationController",     "swift", false, ["XZDefines/XZRuntime"];
  s.defineSubspec "XZCollectionViewFlowLayout", "swift", false, [];
  
  # 工具类
  s.defineSubspec "XZTicker",                   "swift", false, [];
  s.defineSubspec "XZJSON",                     "objc",  true,  ["XZDefines/XZMacros", "XZDefines/XZRuntime", "XZExtensions/NSCharacterSet", "XZExtensions/NSData", "XZObjc"];
  s.defineSubspec "XZLocale",                   "objc",  false, ["XZDefines/XZRuntime", "XZDefines/XZMacros", "XZExtensions/NSString"];
  s.defineSubspec "XZDataCryptor",              "objc",  false, [];
  s.defineSubspec "XZDataDigester",             "objc",  false, ["XZDefines/XZDefer", "XZExtensions/NSData"];
  s.defineSubspec "XZKeychain",                 "objc",  false, [];
  
end

