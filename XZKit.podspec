#
# Be sure to run `pod lib lint XZKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# pod lib lint --verbose

Pod::Spec.new do |s|

  s.cocoapods_version = ">= 1.7.2"

  s.name    = "XZKit"
  s.version = "5.0.0"
  s.summary = "An iOS developing framework"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description = "XZKit is a delightful developing library for iOS!"
  
  s.homepage = 'https://xzkit.xezun.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.author   = { 'xezun' => 'developer@xezun.com' }
  s.source   = { :git => 'https://github.com/xezun/XZKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://xzkit.xezun.com/'
  
  s.module_name    = 'XZKit'
  s.swift_versions = "5.0"
  s.requires_arc   = true
  s.ios.deployment_target = '8.0'
  
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
  s.public_header_files = "XZKit/Code/XZKit.h"
  s.source_files = "XZKit/Code/XZKit.h"
  # 因为分成了多个子模块，指定单一 modulemap 无法适应所有情况，所以需要 Pods 自动生成 modulemap ，而不能指定。
  # s.module_map = 'XZKit/XZKit/module.modulemap'
  # s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
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
  
  # 拓展子库的方法
  def s.defineSubspec (name, hasPrivate)
    return self.subspec name do |ss|
      ss.public_header_files = "XZKit/XZKit.h", 
      						   					 "XZKit/Sources/#{name}/**/*.h"
      ss.source_files  			 = "XZKit/XZKit.h", 
      					 			   			 "XZKit/Sources/#{name}/**/*.{h,m,swift}"
      ss.exclude_files 			 = "XZKit/Sources/#{name}/Private/**/*.{h,m,swift}"

      if hasPrivate then
      	ss.subspec "Private" do |sss|
      		sss.public_header_files = "XZKit/XZKit.h", 
      		"XZKit/Sources/#{name}/**/*.h"
      		sss.source_files = "XZKit/XZKit.h", 
      		"XZKit/Sources/#{name}/**/*.{h,m,swift}"
      	end
      end
    end
  end

  s.defineSubspec "Objective-C", false do |ss| 

  end

  s.defineSubspec "XZKitDefines", false do |ss|
  end

  # s.defineSubspec 'Category' do |ss|
  # end

  # s.defineSubspec 'DataCryptor' do |ss|
  # end
  
  # s.defineSubspec 'DataDigester' do |ss|
  #   ss.dependency "XZKit/Foundation"
  # end

  # s.defineSubspec 'Image' do |ss|
  # 	ss.dependency "XZKit/Foundation"
  # end



  # s.defineSubspec "AppLanguage" do |ss|
  # end

  # s.defineSubspec "AppRedirection" do |ss|
  #   ss.dependency "XZKit/Core"
  # end

  # s.defineSubspec "CacheManager" do |ss|
  #   ss.dependency 'XZKit/Category/Foundation'
  # end
  
  # s.defineSubspec "CarouselView" do |ss|
  #   ss.dependency "XZKit/Core"
  # end
  
  # s.defineSubspec 'ContentStatus' do |ss|
  #   ss.dependency "XZKit/TextImageView"
  # end
  
  
  
  # s.defineSubspec 'NavigationController' do |ss|
  #   ss.dependency "XZKit/Core"
  # end
  
  # s.defineSubspec 'Networking' do |ss|
  # end
  
  # s.defineSubspec 'ProgressView' do |ss|
  # end
  
  # s.defineSubspec 'TimeTicker' do |ss|
  # end
  
  # s.defineSubspec 'TextImageView' do |ss|
  #   ss.dependency "XZKit/Core"
  # end
  
  # s.defineSubspec 'UICollectionViewFlowLayout' do |ss|
  #   ss.dependency "XZKit/Core"
  # end
  
  # s.defineSubspec 'Category' do |ss|
  #   ss.dependency "XZKit/Core"
  #   ss.dependency "XZKit/DataDigester"
  #   ss.dependency "XZKit/DataCryptor"
  #   ss.dependency "XZKit/CacheManager"
  # end
  
end
