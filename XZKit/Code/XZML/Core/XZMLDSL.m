//
//  XZMLDSL.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLDSL.h"

/// XZML 解析过程的中间量。
typedef struct XZMLDSLContext {
    /// XZML 字符串 UTF-8 形式。
    const char * const UTF8String;
    /// XZML 长度，字节数。
    const NSUInteger   length;
    /// 当前指向的字节。
    NSUInteger         index;
} XZMLDSLContext;

/// 判断是否为元素标记。
FOUNDATION_STATIC_INLINE BOOL XZMLDSLIsElement(XZMLElement element) {
    return (element != XZMLElementNotAnElement);
}

/// 从 context 的当前位置开始，查找下一个 ASCII 字符的位置。
static inline NSUInteger XZMLDSLContextSearchASCII(XZMLDSLContext *context) {
    NSUInteger index = context->index;
    // 在 UTF-8 编码中 ASCII 字符是首位为 0 的字节
    while (context->UTF8String[index] & 0b10000000) {
        index += 1;
    }
    return index;
}

/// 跳过当前元素，包括子元素。
static void XZMLElementDSLAbort(XZMLDSLContext * const context, XZMLElement const element, NS_NOESCAPE XZMLDSLShouldBeginElement const shouldBeginElement) {
    BOOL isEscaping = NO;
    do {
        NSUInteger const index = XZMLDSLContextSearchASCII(context);
        context->index = index + 1; // 指向下一个字节

        char const character = context->UTF8String[index];

        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }

        // character 是元素结束字符
        if (character == element) {
            break;
        }
        
        XZMLElement const newElement = shouldBeginElement(character);
        // character 是元素开始字符
        if (XZMLDSLIsElement(newElement)) {
            XZMLElementDSLAbort(context, newElement, shouldBeginElement);
            continue;
        }
    } while (context->index < context->length);
}

/// 仅识别当前元素中的文本，忽略属性。
static NSString *XZMLElementDSLText(XZMLDSLContext * const context, XZMLElement const element, NS_NOESCAPE XZMLDSLShouldBeginElement const shouldBeginElement, NS_NOESCAPE XZMLDSLShouldBeginAttribute const shouldBeginAttribute) {
    NSMutableString * const value = [NSMutableString stringWithCapacity:context->length - context->index];
    
    /// 当前循环轮次是否处于逃逸模式
    BOOL isEscaping = NO;
    /// 当前元素是否应该继续识别属性
    BOOL shouldRecognizeAttributes = YES;
    
    /// 因为元素识别是从元素开始标记后的第一个字符开始，所以直接用 do-while 循环。
    do {
        NSUInteger const index = XZMLDSLContextSearchASCII(context);
        if (context->index < index) {
            // 当前字符被跳过了，说明是非 ASCII 字符。
            const char * const bytes = context->UTF8String + context->index;
            NSUInteger   const count = index - context->index;
            NSString *string = [[NSString alloc] initWithBytes:bytes length:count encoding:NSUTF8StringEncoding];
            [value appendString:string];
        }
        context->index = index + 1; // 指向下一个字节

        char const character = context->UTF8String[index];

        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            [value appendFormat:@"%c", character];
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }

        // character 是元素结束字符
        if (character == element) {
            break;
        }

        // 先判断是否为元素标记字符，后判断是否为属性标记字符。
        XZMLElement const newElement = shouldBeginElement(character);

        // 子元素开始：character 是元素开始字符
        if (XZMLDSLIsElement(newElement)) {
            // 标记当前元素不再识别属性标记
            shouldRecognizeAttributes = NO;
            
            // 识别子元素
            NSString * substring = XZMLElementDSLText(context, newElement, shouldBeginElement, shouldBeginAttribute);
            [value appendString:substring];
            continue;
        }

        // 属性：character 是元素属性字符
        if (shouldRecognizeAttributes && shouldBeginAttribute(element, character)) {
            // 已识别的字符为属性，直接删除
            [value deleteCharactersInRange:NSMakeRange(0, value.length)];
            continue;
        }

        // character 是元素文本字符
        [value appendFormat:@"%c", character];
    } while (context->index < context->length);

    return value;
}

/// 元素识别。
/// 传入的 context->index 指向当前元素开始标记之后第一个字符，
/// 本函数执行完毕 context->index 执行元素结束标记之后的第一个字符，或者指向字符串结束标志`\0`。
static void XZMLElementDSL(XZMLDSLContext * const context,
                           XZMLElement const element,
                           NS_NOESCAPE XZMLDSLShouldBeginElement const shouldBeginElement,
                           NS_NOESCAPE XZMLDSLShouldBeginAttribute const shouldBeginAttribute,
                           NS_NOESCAPE XZMLDSLDidBeginElement const didBeginElement,
                           NS_NOESCAPE XZMLDSLFoundAttribute const foundAttribute,
                           NS_NOESCAPE XZMLDSLFoundTextFragment const foundTextFragment,
                           NS_NOESCAPE XZMLDSLDidEndElement const didEndElement) {
    // 发送元素识别开始事件
    didBeginElement(element);
    
    NSMutableString * const value = [NSMutableString stringWithCapacity:context->length - context->index];
    
    /// 文本段
    NSUInteger fragment = 0;
    /// 当前循环轮次是否处于逃逸模式
    BOOL isEscaping = NO;
    /// 当前元素是否应该继续识别属性
    BOOL shouldRecognizeAttributes = YES;
    
    /// 因为元素识别是从元素开始标记后的第一个字符开始，所以直接用 do-while 循环。
    do {
        NSUInteger const index = XZMLDSLContextSearchASCII(context);
        if (context->index < index) {
            // 当前字符被跳过了，说明是非 ASCII 字符。
            const char * const bytes = context->UTF8String + context->index;
            NSUInteger   const count = index - context->index;
            NSString *string = [[NSString alloc] initWithBytes:bytes length:count encoding:NSUTF8StringEncoding];
            [value appendString:string];
        }
        context->index = index + 1; // 指向下一个字节

        char const character = context->UTF8String[index];

        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            [value appendFormat:@"%c", character];
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }

        // character 是元素结束字符
        if (character == element) {
            break;
        }

        // 先判断是否为元素标记字符，后判断是否为属性标记字符。
        XZMLElement const newElement = shouldBeginElement(character);

        // 子元素开始：character 是元素开始字符
        if (XZMLDSLIsElement(newElement)) {
            // 标记当前元素不再识别属性标记
            shouldRecognizeAttributes = NO;
            
            // 发送文本识别事件：已识别的字符作为文本属性
            NSUInteger const length = value.length;
            if (length > 0) {
                foundTextFragment(element, value.copy, fragment++);
                [value deleteCharactersInRange:NSMakeRange(0, length)];
            }
            
            // 识别子元素
            XZMLElementDSL(context, newElement, shouldBeginElement, shouldBeginAttribute, didBeginElement, foundAttribute, foundTextFragment, didEndElement);
            continue;
        }

        // character 是元素属性字符
        if (shouldRecognizeAttributes && shouldBeginAttribute(element, character)) {
            NSString * const attributeValue = value.copy;
            [value deleteCharactersInRange:NSMakeRange(0, value.length)];
            
            // 发送属性识别事件
            XZMLReadingOptions const mode = foundAttribute(element, character, attributeValue);
            if (mode == XZMLReadingAll) {
                continue;
            }
            
            if (mode == XZMLReadingText) {
                // 提出文本
                [value appendString:XZMLElementDSLText(context, element, shouldBeginElement, shouldBeginAttribute)];
            } else if (mode == XZMLReadingNone) {
                // 终止当前元素
                XZMLElementDSLAbort(context, element, shouldBeginElement);
            }
            break;
        }

        // character 是元素文本字符
        [value appendFormat:@"%c", character];
    } while (context->index < context->length);

    // 发送文本识别事件：已识别的字符作为文本属性
    foundTextFragment(element, value, fragment);
    
    // 发送元素识别结束事件
    didEndElement(element);
}

void XZMLDSL(NSString *XZMLString,
             NS_NOESCAPE XZMLDSLShouldBeginElement const shouldBeginElement,
             NS_NOESCAPE XZMLDSLShouldBeginAttribute const shouldBeginAttribute,
             NS_NOESCAPE XZMLDSLDidBeginElement const didBeginElement,
             NS_NOESCAPE XZMLDSLFoundAttribute const foundAttribute,
             NS_NOESCAPE XZMLDSLFoundTextFragment const foundTextFragment,
             NS_NOESCAPE XZMLDSLDidEndElement const didEndElement) {
    NSCAssert([XZMLString isKindOfClass:NSString.class], @"XZML 必须为字符串");

    // 得到 UTF-8 编码的 C 字符串，以及字符串字节长度。
    const char * const str = [XZMLString cStringUsingEncoding:NSUTF8StringEncoding];
    const NSUInteger   len = [XZMLString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    XZMLDSLContext context = { str, len, 0 };
    BOOL isEscaping = NO;
    NSUInteger fragment = 0;
    
    // 遍历整个字符串，遍历完成后，context.index 指向字符串最后一个字符后面的位置
    NSInteger start = context.index;
    while (context.index < context.length) {
        NSInteger const index = XZMLDSLContextSearchASCII(&context);
        context.index = index + 1; // 指向下一个字符
        
        char const character = context.UTF8String[index];
        
        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }
        
        XZMLElement const element = shouldBeginElement(character);
        if (XZMLDSLIsElement(element)) {
            // 识别元素前，处理非元素文本。
            if (start < index) {
                const char * const bytes = context.UTF8String + start;
                NSUInteger   const count = index - start;
                NSString *value = [[NSString alloc] initWithBytes:bytes length:count encoding:NSUTF8StringEncoding];
                foundTextFragment(XZMLElementNotAnElement, value, fragment++);
            }

            // 然后开始识别元素。
            XZMLElementDSL(&context, element, shouldBeginElement, shouldBeginAttribute, didBeginElement, foundAttribute, foundTextFragment, didEndElement);

            // 元素识别完成后，记录位置。
            start = context.index;
        }
    }
    
    // 最后一个元素结束时，字符串后面依然有字符。
    if (start < context.index) {
        const char * const bytes = context.UTF8String + start;
        NSUInteger   const count = context.index - start;
        NSString *value = [[NSString alloc] initWithBytes:bytes length:count encoding:NSUTF8StringEncoding];
        foundTextFragment(XZMLElementNotAnElement, value, fragment);
    }
}
