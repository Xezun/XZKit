//
//  XZML.Private.h
//  XZML
//
//  Created by Xezun on 2020/7/20.
//  Copyright © 2020 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define XZML_MAX_ATTRS 8

typedef struct {
    /// XZML 字符串。
    char const * const xzmlcs;
    /// XZML 长度。
    NSInteger const    length;
    /// 当前处理中的子字符串 range 。
    NSRange   srange;
    /// 子字符串包含的属性个数（子字符串中 @ 的个数）。
    NSInteger attspc;
    /// 每个属性的 range 。
    NSRange   attspr[XZML_MAX_ATTRS];
} XZMLContext;

static inline BOOL XZMLContextSearchASCIICharacter(XZMLContext *context) {
    NSInteger index = context->srange.location + context->srange.length;
    while (index < context->length) {
        char const character = context->xzmlcs[index];
        if (character & 0b10000000) {
            context->srange.length += 1;
            index = context->srange.location + context->srange.length;
            continue;
        }
        return YES;
    }
    return NO;
}

static inline char const *XZMLContextGetValue(XZMLContext *context) {
    return context->xzmlcs + context->srange.location;
}

static inline NSInteger XZMLContextGetValueLength(XZMLContext *context) {
    return context->srange.length;
}

static inline char const *XZMLContextGetAttribute(XZMLContext *context, NSInteger index) {
    return context->xzmlcs + context->attspr[index].location;
}

static inline NSInteger XZMLContextGetAttributeLength(XZMLContext *context, NSInteger index) {
    return context->attspr[index].length;
}

/// 将 context 定位到当前位置，并重置状态。
static inline void XZMLContextMoveAndPrepare(XZMLContext *context) {
    context->srange.location = context->srange.location + context->srange.length + 1;
    context->srange.length = 0;
    // 新样式的属性开始
    context->attspc = 0;
    context->attspr[0].location = context->srange.location;
    context->attspr[0].length = 0;
}

#pragma mark - 字符串解析

/// 字符串转颜色。
extern UIColor *UIColorFromCharacters(char const *characters, NSInteger const length);
/// 字符串转整数
extern NSInteger NSIntegerFromCharacters(char const * characters, NSInteger length);
/// 字符串转浮点数
extern CGFloat CGFloatFromCharacters(char const * characters, NSInteger length);


#pragma mark - XZML


extern UIColor *UIColorFromXZMLContext(XZMLContext *context, NSInteger index, UIColor *defaultColor);
extern NSString *NSStringFromXZMLContext(XZMLContext *context, NSInteger index);

/// 转 UIColor
UIColor *XZMLColorParser(XZMLContext *context, UIColor *defaultColor);
/// context 转成 NSString .
extern NSString * _Nullable XZMLStringParser(XZMLContext *context);
/// 将 context 中内容合并到 attributedStringM 中。
extern void XZMLParserMergeString(XZMLContext *context, NSMutableAttributedString *attributedStringM, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes);
/// 删除线
extern void XZMLAttributeUnderlineParser(XZMLContext *context, NSMutableDictionary<NSAttributedStringKey, id> *attributes);
/// 字体颜色
extern void XZMLAttributeForegroundColorParser(XZMLContext *context, NSMutableDictionary<NSAttributedStringKey, id> *attributes);
/// 字体
extern void XZMLAttributeFontParser(XZMLContext *context, NSMutableDictionary<NSAttributedStringKey, id> *attributes);
/// 变星。
extern NSInteger XZMLAttributeStarParser(XZMLContext *context);


NS_ASSUME_NONNULL_END
