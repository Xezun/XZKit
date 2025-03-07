//
//  UIDevice+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/11/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (XZKit)

/// 设备型号，如 iPhone10,1 等。
@property (nonatomic, readonly, nullable) NSString *xz_productModel NS_SWIFT_NAME(productModel);
/// 主板型号，如 D20AP 等。
@property (nonatomic, readonly, nullable) NSString *xz_boardModel NS_SWIFT_NAME(boardModel);
/// 产品名称，如 iPhone SE 2 或 iPhone 等。
@property (nonatomic, readonly) NSString *xz_productName NS_SWIFT_NAME(productName);

@end

NS_ASSUME_NONNULL_END
