//
//  XZNSTimeInterval.h
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 获取当前时间戳，精确到微秒（μs）。
/// @note 在 Swift 中，请使用 `TimeInterval.since1970` 代替。
/// @note 相较 `NSDate.date.timeIntervalSince1970` 性能约提升 40% （0.33μs -> 0.19μs，仅供参考）。
/// @return 单位为秒，小数点后为微秒。
FOUNDATION_EXTERN NSTimeInterval XZTimestamp(void) NS_REFINED_FOR_SWIFT;


NS_ASSUME_NONNULL_END
