//
//  XZDefer.h
//  XZKit
//
//  Created by Xezun on 2023/8/6.
//

#import <Foundation/Foundation.h>
#import "XZMacro.h"

NS_ASSUME_NONNULL_BEGIN

#ifndef defer

/// 包装 defer 代码的块函数类型。
typedef void (^__xz_defer_t__)(void) NS_SWIFT_UNAVAILABLE("Use Swift.defer instead");

/// 执行包装了 defer 代码的块函数的函数。
/// @param statements 需要延迟执行的代码块
FOUNDATION_EXPORT void __xz_defer_imp__(__strong __xz_defer_t__ _Nonnull * _Nonnull statements) NS_SWIFT_UNAVAILABLE("Use Swift.defer instead");

/// 延迟到当前作用域结束后才执行的代码块。
/// @note 声明了此函数，以解决宏参数不能自动补全类型的问题，即实际上此函数不会被执行。
/// @param statements 延迟执行的语句
FOUNDATION_EXPORT void defer(__xz_defer_t__ statements) NS_SWIFT_UNAVAILABLE("Use Swift.defer instead");

#undef defer
#define defer(statements) __xz_defer_t__ __strong xz_macro_paste(__xz_defer_, __LINE__) __attribute__((cleanup(__xz_defer_imp__), unused)) = statements

#endif

NS_ASSUME_NONNULL_END
