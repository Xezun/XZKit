//
//  XZML.h
//  XZML
//
//  Created by Xezun on 2020/7/18.
//  Copyright © 2020 Xezun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// XZML 对齐方式。
typedef NS_OPTIONS(NSUInteger, XZMLAlignments) {
    /// 默认，不进行任何对齐设置，即由系统默认规则决定。
    XZMLAlignmentDefault = 0,
    /// 垂直居中对齐。
    XZMLAlignmentVerticalMiddle = 1 << 0
};

/// XZML 解析函数。
/// @param xzmlString XZML格式的字符串。
/// @param attributes 默认样式。
/// @param alignments 对齐方式。
/// @param securityMode 是否保密模式。
NSAttributedString *XZMLParser(NSString *xzmlString, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes, XZMLAlignments alignments, BOOL securityMode);


NS_ASSUME_NONNULL_END
