//
//  macro.h
//  XZKit
//
//  Created by Xezun on 2021/4/21.
//

#import <Foundation/Foundation.h>

#ifndef macro_h
#define macro_h

/// 将两个参数粘贴在一起。
#define macro_paste(A, B) __NSX_PASTE__(A, B)

/// 获取宏参数列表中的第 N 个参数。
#define macro_args_at(N, ...) macro_paste(macro_args_at, N)(__VA_ARGS__)

/// 获取参数列表中的第一个个参数。
#define macro_args_first(...) macro_args_first_imp(__VA_ARGS__, 0)

/// 获取参数列表中参数的个数（最多10个）。
/// 在参数列表后添加从 10 到 1 的数字，取得第 11 个元素，就是原始参数列表的个数。
#define macro_args_count(...) macro_args_at(10, __VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

/// 遍历参数列表：对参数列表中的参数，逐个应用 MACRO(INDEX, ARG) 宏函数，使用 SEP 分隔每次宏函数展开。
#define macro_args_map(MACRO, SEP, ...) macro_args_map_imp(macro_args_map_ctx, SEP, MACRO, __VA_ARGS__)

/// 宏 macro_args_at 的实现：
/// 通过 macro_paste 拼接 N 后，就变成下面对应的宏，
/// 由于 0 到 N - 1 之间的参数已占位，这样参数列表 ... 就是 N 及之后的参数，
/// 然后获取这个参数列表的第一个参数，即是原始参数列表的第 N 个参数。
#define macro_args_at0(...) macro_args_first(__VA_ARGS__)
#define macro_args_at1(_0, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at2(_0, _1, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at3(_0, _1, _2, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at4(_0, _1, _2, _3, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at5(_0, _1, _2, _3, _4, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at6(_0, _1, _2, _3, _4, _5, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at7(_0, _1, _2, _3, _4, _5, _6, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) macro_args_first(__VA_ARGS__)
#define macro_args_at10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) macro_args_first(__VA_ARGS__)

/// 宏 macro_args_first 的实现。
#define macro_args_first_imp(FIRST, ...) FIRST

/// 宏 macro_args_map 的实现：根据参数的个数，展开成相应的具体实现。
/// @define
/// @function macro_args_map
/// @param CONTEXT 可承接一次 MACRO 参数的转换
/// @param SEP 间隔符
/// @param MACRO 遍历参数所执行的宏
/// @param ... 参数列表
#define macro_args_map_imp(CONTEXT, SEP, MACRO, ...) \
        macro_paste(macro_args_map_imp, macro_args_count(__VA_ARGS__))(CONTEXT, SEP, MACRO, __VA_ARGS__)
#define macro_args_map_ctx(INDEX, MACRO, ARG) MACRO(INDEX, ARG)

#define macro_args_map_imp0(CONTEXT, SEP, MACRO)
#define macro_args_map_imp1(CONTEXT, SEP, MACRO, _0) CONTEXT(0, MACRO, _0)

#define macro_args_map_imp2(CONTEXT, SEP, MACRO, _0, _1) \
    macro_args_map_imp1(CONTEXT, SEP, MACRO, _0) \
    SEP \
    CONTEXT(1, MACRO, _1)

#define macro_args_map_imp3(CONTEXT, SEP, MACRO, _0, _1, _2) \
    macro_args_map_imp2(CONTEXT, SEP, MACRO, _0, _1) \
    SEP \
    CONTEXT(2, MACRO, _2)

#define macro_args_map_imp4(CONTEXT, SEP, MACRO, _0, _1, _2, _3) \
    macro_args_map_imp3(CONTEXT, SEP, MACRO, _0, _1, _2) \
    SEP \
    CONTEXT(3, MACRO, _3)

#define macro_args_map_imp5(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4) \
    macro_args_map_imp4(CONTEXT, SEP, MACRO, _0, _1, _2, _3) \
    SEP \
    CONTEXT(4, MACRO, _4)

#define macro_args_map_imp6(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5) \
    macro_args_map_imp5(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4) \
    SEP \
    CONTEXT(5, MACRO, _5)

#define macro_args_map_imp7(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6) \
    macro_args_map_imp6(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5) \
    SEP \
    CONTEXT(6, MACRO, _6)

#define macro_args_map_imp8(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7) \
    macro_args_map_imp7(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6) \
    SEP \
    CONTEXT(7, MACRO, _7)

#define macro_args_map_imp9(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
    macro_args_map_imp8(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7) \
    SEP \
    CONTEXT(8, MACRO, _8)

#define macro_args_map_imp10(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
    macro_args_map_imp9(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
    SEP \
    CONTEXT(9, MACRO, _9)

#endif /* macro_h */
