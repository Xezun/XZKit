//
//  XZImageAttribute.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 作为矩形属性的基类。仅内部使用，外部不可初始化。
NS_SWIFT_NAME(XZImage.Attribute)
@interface XZImageAttribute : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
