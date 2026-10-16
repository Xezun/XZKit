//
//  XZMLDSL.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 解析 XZML 字符串，将样式化的富文本追加到 `attributedString` 末尾。
///
/// 解析过程中的非法输入均降级处理、不抛异常：非字符串与空串不产生任何内容。
/// 词法解析按组合字符序列（而非 UTF-8 字节流）逐个扫描，因此含未配对代理项等无法表示为 UTF-8
/// 的字符串也会正常解析，此类字符作为普通文本保留在解析结果中。
///
/// - Parameters:
///   - XZMLString: XZML 字符串
///   - attributedString: 接收解析结果的富文本对象，内容由本函数追加
///   - attributes: 默认样式与预设样式，可为 nil，详见 `XZMLAttributeName` 的取值优先级说明
FOUNDATION_EXPORT void XZMLDSLWithAttributedString(NSString *XZMLString, NSMutableAttributedString *attributedString, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes);

/// 解析 XZML 字符串，仅提取纯文本并追加到 `string` 末尾，丢弃除安全模式以外的所有样式。
///
/// 安全模式（`XZMLSecurityModeAttributeName` 为 YES）下仍会执行星号遮蔽替换。
///
/// - Parameters:
///   - XZMLString: XZML 字符串
///   - string: 接收解析结果的字符串，内容由本函数追加
///   - attributes: 默认样式与预设样式，可为 nil
FOUNDATION_EXPORT void XZMLDSLWithString(NSString *XZMLString, NSMutableString *string, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes);

NS_ASSUME_NONNULL_END
