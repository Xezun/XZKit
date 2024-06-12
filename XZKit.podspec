#
# Be sure to run `pod lib lint XZKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# pod lib lint --verbose

Pod::Spec.new do |s|

  s.cocoapods_version = ">= 1.7.2";

  s.name    = "XZKit";
  s.version = "6.0.0";
  s.summary = "An iOS developing framework";

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description = "XZKit is a delightful developing library for iOS!";
  
  s.homepage = 'https://www.xezun.com';
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license  = { :type => 'MIT', :file => 'LICENSE' };
  s.author   = { 'xezun' => 'developer@xezun.com' };
  s.source   = { :git => 'https://github.com/xezun/XZKit.git', :tag => s.version.to_s };
  s.social_media_url = 'https://www.xezun.com';
  
  s.module_name    = 'XZKit';
  s.swift_versions = "5.0";
  s.requires_arc   = true;
  s.ios.deployment_target = '12.0';
  
  # s.xcconfig = {
  #   "GCC_PREPROCESSOR_DEFINITIONS" => '$(inherited) XZKIT_FRAMEWORK=1'
  # }
  # s.pod_target_xcconfig = {
  #     'OTHER_CFLAGS' => '-fembed-bitcode'
  #     'DEFINES_MODULE' => 'YES'
  # }
  
  # 使用 .framework 作为 Pods 源时。
  # s.vendored_frameworks = 'Products/XZKit.framework'
  
  # 框架文件和公共头文件。
  # XZKit.h 没有这个头文件会导致无法编译，Xcode 编译 framework 时自动生成的桥接头文件 XZKit-Swift.h 文件包含该文件。
  # s.public_header_files = "XZKit/XZKit.h";
  # s.source_files = "XZKit/XZKit.h";
  # 因为分成了多个子模块，指定单一 modulemap 无法适应所有情况，所以需要 Pods 自动生成 modulemap ，而不能指定。
  # s.module_map = 'XZKit/XZKit/module.modulemap'
  # s.frameworks = 'UIKit'
  
  s.dependency 'XZExtensions'
  s.dependency 'XZPageControl'
  s.dependency 'XZRefresh'
  s.dependency 'XZCollectionViewFlowLayout'
  s.dependency 'XZMocoa'
  s.dependency 'XZShapeView'
  s.dependency 'XZPageView'
  s.dependency 'XZML'
  s.dependency 'XZDefines'
  s.dependency 'XZURLQuery'

  # 默认使用 XZKit.framework
  # s.default_subspecs = "XZKit"
  
  # 源代码，整个框架。
  # s.subspec "XZKit" do |ss|
  #     # ss.resource_bundles = {
  #         # 须使用 +bundleForClass: 方法构造的 NSBundle 来获取资源。
  #         # +bundleWithIdentifier: 构造的 NSBundle 无法获取资源 iOS 11，原因未知。
  #     #    'XZKit' => ['XZKit/Resource/Assets.xcassets']
  #     # }
  #     ss.public_header_files = 'XZKit/Code/**/*.h'
  #     ss.source_files = 'XZKit/Code/**/*.{h,m,swift}'
  # end
  
  # 子框架
  
  # 已编译的框架包。
  # s.subspec 'Framework' do |ss|
  #     ss.vendored_frameworks = 'Products/XZKit.framework'
  # end
  
  # 定义子库的拓展方法
  # @param specName 字符串，子库的名字
  # @param hasPrivate 布尔，是否有私有目录
  # @param dependencies 数组，依赖的库，没有填空数组[]
  # def s.defineSubspec (specName, hasPrivate, dependencies)
  #   return self.subspec specName do |ss|
  #     ss.public_header_files = "XZKit/XZKit.h", "XZKit/Sources/#{specName}/**/*.h";
  #     ss.source_files  			 = "XZKit/XZKit.h", "XZKit/Sources/#{specName}/**/*.{h,m,swift}";

  #     if hasPrivate then
  #     	ss.exclude_files = "XZKit/Sources/#{specName}/Private/**/*.{h,m,swift}";
  #       # 二级子库，默认包含它的三级子库
  #       # Private 库包含所有文件，是一个完整独立库，因为 CocoaPods 的任何子库都必须能单独使用才能通过验证。
  #       # private_header_files 文件可以被手动引用，但是这里因为在子库，如果不设置为 private 父库会引用不到。
  #     	ss.subspec "Private" do |sss|
  #     		sss.public_header_files  = "XZKit/XZKit.h", "XZKit/Sources/#{specName}/**/*.h";
  #         sss.private_header_files = "XZKit/Sources/#{specName}/Private/**/*.{h,m,swift}";
  #     		sss.source_files         = "XZKit/XZKit.h", "XZKit/Sources/#{specName}/**/*.{h,m,swift}";

  #         dependencies.each do |dependency|
  #           sss.dependency dependency;
  #         end
  #     	end
  #     else
  #       dependencies.each do |dependency|
  #         ss.dependency dependency;
  #       end
  #     end
  #   end
  # end
  
  # s.defineSubspec "XZKitDefines",     	        false, [];
  # s.defineSubspec "XZKitDEBUG",                 false, ["XZKit/XZKitDefines"];
  # s.defineSubspec "XZDefer",                    false, ["XZKit/XZKitDefines"]
  # s.defineSubspec "XZLog",                      false, ["XZKit/XZKitDefines", "XZKit/XZKitDEBUG"];
  # s.defineSubspec "XZCharacterCase",            false, [];
  # s.defineSubspec "XZGeometry",                 false, ["XZKit/XZKitDefines"];
  # s.defineSubspec "XZHexEncoding",              false, ["XZKit/XZKitDefines", "XZKit/XZCharacterCase"];
  # s.defineSubspec "XZJSON",                     false, [];
  # s.defineSubspec "XZRuntime",                  false, ["XZKit/XZKitDefines", "XZKit/XZLog", "XZKit/XZGeometry"];
  # s.defineSubspec "XZTimestamp",                false, [];
  # s.defineSubspec "XZCategory",                 false, [];
  # s.defineSubspec "XZDataDigester",             false, ["XZKit/XZCharacterCase", "XZKit/XZHexEncoding", "XZKit/XZDefer"];
  # s.defineSubspec "XZDataCryptor",              false, [];
  # s.defineSubspec "XZColor",                    false, [];
  # s.defineSubspec "XZImage",                    true,  [];
  # s.defineSubspec "XZNavigationController",     false, [];
  
end
