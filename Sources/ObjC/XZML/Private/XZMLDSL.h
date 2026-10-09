//
//  XZMLDSL.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// XZML 元素的开始和结束标记，固定为 `<` 和 `>` 字符，不支持自定义。
#define XZMLElementStart '<'
#define XZMLElementEnd   '>'

@class XZMLParser;

/// XZML 语法解析函数。
/// - Parameters:
///   - XZMLString: XZML 字符串
///   - parser: 解析
FOUNDATION_EXPORT void XZMLDSL(NSString *XZMLString, XZMLParser *parser);

NS_ASSUME_NONNULL_END
