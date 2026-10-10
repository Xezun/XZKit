//
//  XZMLDSL.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZMLParser;

/// XZML 语法解析函数。
/// - Parameters:
///   - XZMLString: XZML 字符串
///   - parser: 解析
FOUNDATION_EXPORT void XZMLDSL(NSString *XZMLString, XZMLParser *parser);

NS_ASSUME_NONNULL_END
