//
//  UIKit+XZML.h
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import <UIKit/UIKit.h>
#import "XZMLDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (XZML)

/// 设置 XZML 格式的文本。
///
/// 如果参数 attributes 中没有提供 NSFontAttributeName、NSForegroundColorAttributeName 属性，则将 .font、.textColor 作为默认值。
///
/// - Parameters:
///   - XZMLString: XZML 文本
///   - attributes: 文本样式属性
- (void)setXZMLText:(nullable NSString *)XZMLString attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/// 设置 XZML 格式的文本。
/// - Parameters:
///   - XZMLString: XZML 文本
- (void)setXZMLText:(nullable NSString *)XZMLString;

@end

@interface UIButton (XZML)

/// 设置 XZML 格式的标题文本。
///
/// 如果参数 attributes 中没有提供 NSFontAttributeName、NSForegroundColorAttributeName 属性，
/// 则将 .titleLabel.font、-titleColorForState: 作为默认值。
///
/// - Parameters:
///   - XZMLString: XZML 文本
///   - state: 状态
///   - attributes: 文本样式属性
- (void)setXZMLTitle:(nullable NSString *)XZMLString forState:(UIControlState)state attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/// 设置 XZML 格式的标题文本。
/// - Parameters:
///   - XZMLString: XZML 文本
///   - state: 状态
- (void)setXZMLTitle:(nullable NSString *)XZMLString forState:(UIControlState)state;

@end

@interface UITextView (XZML)

/// 设置 XZML 格式的文本。
///
/// 如果参数 attributes 中没有提供 NSFontAttributeName、NSForegroundColorAttributeName 属性，则将 .font、.textColor 作为默认值。
///
/// - Parameters:
///   - XZMLString: XZML 文本
///   - attributes: 文本样式属性
- (void)setXZMLText:(nullable NSString *)XZMLString attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/// 设置 XZML 格式的文本。
/// - Parameters:
///   - XZMLString: XZML 文本
- (void)setXZMLText:(nullable NSString *)XZMLString;

@end

@interface UITextField (XZML)

/// 设置 XZML 格式的文本。
///
/// 如果参数 attributes 中没有提供 NSFontAttributeName、NSForegroundColorAttributeName 属性，则将 .font、.textColor 作为默认值。
/// 
/// - Parameters:
///   - XZMLString: XZML 文本
///   - attributes: 文本样式属性
- (void)setXZMLText:(nullable NSString *)XZMLString attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/// 设置 XZML 格式的文本。
/// - Parameters:
///   - XZMLString: XZML 文本
- (void)setXZMLText:(nullable NSString *)XZMLString;

@end

NS_ASSUME_NONNULL_END
