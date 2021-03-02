//
//  XZDefer.h
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

/// defer 闭包的执行函数，请不要直接调用此函数。
/// @param operation 待执行的清理操作。
FOUNDATION_EXPORT void __XZ_DEFER_OBSV__(void (^ _Nonnull * _Nonnull operation)(void)) XZ_OBJC_ONLY;

#define __XZ_DEFER_ATTR__        XZ_ATTR(XZ_ATTR_OBSERVER(__XZ_DEFER_OBSV__), XZ_ATTR_UNUSED)
#define __XZ_DEFER_IMPL__(L, S)  void (^__NSX_PASTE__(__XZ_DEFER_STMT_, L))(void) __XZ_DEFER_ATTR__ = S

/// 添加到 XZDefer 的代码块 operation 将被延迟到作用域结束时执行。
/// @note 如果可能，请尝试使用 defer 函数。
FOUNDATION_EXPORT void XZDefer(void (^operation)(void)) XZ_OBJC_ONLY;
#undef  XZDefer
#define XZDefer(statements) __XZ_DEFER_IMPL__(__COUNTER__, statements)


#ifndef XZ_DEFER_SUPPORTED
#define XZ_DEFER_SUPPORTED 1
/// 添加到 defer 的代码块 operation 将被延迟到作用域结束时执行。
/// @note 这在函数返回时，需要执行清理操作的逻辑中，特别是有多个返回分支的逻辑中非常有用，可以提前处理清理逻辑。
/// @param operation 需执行的代码。
/// @code
/// - (void)fooBar {
///     DataBase *db = [DataBase dataBase];
///
///     DBSet *set = [db open:@"SELECT * FROM table"];
///     defer({
///         [db close]; // db will be closed when current method ends or returns.
///     });
///
///     // ... more operations with the db.
/// }
/// @endcode
FOUNDATION_EXPORT void defer(void (^operation)(void)) XZ_OBJC_ONLY;

#undef defer
#define defer(statements) XZDefer(statements)

#endif

NS_ASSUME_NONNULL_END
