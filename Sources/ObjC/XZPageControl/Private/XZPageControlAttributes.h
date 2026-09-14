//
//  XZPageControlAttributes.h
//  XZPageControl
//
//  Created by Xezun on 2024/6/10.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZPageControlDefines.h>
#else
#import "XZPageControlDefines.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 记录样式信息的对象。
/// 1、记录指示器默认样式，当设置指示器默认样式时，样式值会保存在此对象中。
/// 2、创建新的指示器 Item 时，被保存的默认样式，会复制到指示器 Item 中。
/// 3、在指示器视图创建前，对指示器的样式修改，实际保存在 Attributes 对象中。
/// 4、当创建指示器视图时，Item 中的样式值，会应用到视图中。
/// 5、指示器视图创建后，对指示器样式的修改，在保存到 Attributes 的同时，会同时应用到视图。
@interface XZPageControlAttributes : NSObject <NSCopying, XZPageControlIndicator>
@end

NS_ASSUME_NONNULL_END
