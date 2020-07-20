//
//  XZML.h
//  XZML
//
//  Created by Xezun on 2020/7/18.
//  Copyright © 2020 Xezun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 对齐方式。
typedef NS_OPTIONS(NSUInteger, XZMLAlignments) {
    XZMLAlignmentDefault = 0,
    // 垂直居中对齐。
    XZMLAlignmentMiddle = 1 << 0
};

NSAttributedString *XZMLParser(NSString *xzmlString, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes, XZMLAlignments alignments, BOOL securityMode);


NS_ASSUME_NONNULL_END
