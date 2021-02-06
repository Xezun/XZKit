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
/// - XZCharacterLowercase: 小写字符，默认。
/// - XZCharacterUppercase: 大写字符。
typedef NS_ENUM(NSInteger, XZCharacterCase) {
    XZCharacterLowercase = 0,
    XZCharacterUppercase = 1
} NS_SWIFT_NAME(CharacterCase);

NS_ASSUME_NONNULL_END
