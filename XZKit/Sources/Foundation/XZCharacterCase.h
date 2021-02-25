//
//  XZCharacterCase.h
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 字符串字符大小写样式。
typedef NS_ENUM(NSInteger, XZCharacterCase) {
    /// 小写字符，默认。
    XZCharacterLowercase = 0,
    /// 大写字符。
    XZCharacterUppercase = 1
};

NS_ASSUME_NONNULL_END
