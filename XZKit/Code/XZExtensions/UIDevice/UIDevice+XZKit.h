//
//  UIDevice+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/11/21.
//

#import <UIKit/UIKit.h>
@import XZDefines;

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (XZKit)

/// 设备型号，如 iPhone10,1 等。
@property (nonatomic, readonly, nullable) NSString *xz_productModel NS_SWIFT_NAME(productModel);
/// 主板型号，如 D20AP 等。
@property (nonatomic, readonly, nullable) NSString *xz_boardModel NS_SWIFT_NAME(boardModel);

@end

NS_ASSUME_NONNULL_END
