//
//  XZMLDSL.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLDSL.h"
#import "XZMLParser.h"

/// XZML 解析过程的中间量。
typedef struct XZMLDSLContext {
    /// XZML 字符串 UTF-8 形式。
    const char * const UTF8String;
    /// XZML 长度，字节数。
    const NSUInteger   length;
    /// 当前指向的字节。
    NSUInteger         index;
    ///
    XZMLParser * const __unsafe_unretained parser;
} XZMLDSLContext;

/// 从 context 的当前位置开始，查找下一个 ASCII 字符的位置。
/// 如果当前位置就是 ASCII 字符，那么直接返回当前的 index 值。
static inline NSUInteger XZMLDSLContextSearchASCII(XZMLDSLContext *context) {
    NSUInteger index = context->index;
    // 在 UTF-8 编码中 ASCII 字符是首位为 0 的字节
    // 只有 index 在安全范围内时，才会调用到此函数，而此循环扫描到字符串结尾 \0 时，也会结束循环，
    // 所以不需要判断 index 是否在合法范围内
    while (context->UTF8String[index] & 0b10000000) {
        index += 1;
    }
    return index;
}

/// 判断字符是否为 XZML 属性标记符。
static inline BOOL XZMLDSLAttributeCharacter(XZMLDSLContext *context, char character) {
    return ((BOOL (*)(id, SEL, char))(context->parser->_isAttributeCharacter))(context->parser, @selector(isAttributeCharacter:), character);
}

static inline void XZMLDSLDidBeginElement(XZMLDSLContext *context) {
    ((void (*)(id, SEL))(context->parser->_didBeginElement))(context->parser, @selector(didBeginElement));
}

static inline void XZMLDSLFoundText(XZMLDSLContext *context, NSString *value, NSUInteger fragment) {
    (((void (*)(id, SEL, NSString *, NSUInteger))(context->parser->_foundText))(context->parser, @selector(foundText:fragment:), value, fragment));
}

static inline XZMLReadingMode XZMLDSLFoundAttribute(XZMLDSLContext *context, XZMLAttribute attribute, NSString *value) {
    return (((XZMLReadingMode (*)(id, SEL, XZMLAttribute, NSString *))(context->parser->_foundAttribute))(context->parser, @selector(foundAttribute:value:), attribute, value));
}

static inline void XZMLDSLDidEndElement(XZMLDSLContext *context) {
    ((void (*)(id, SEL))(context->parser->_didEndElement))(context->parser, @selector(didEndElement));
}

/// 跳过当前元素，包括子元素。
static void XZMLElementDSLAbort(XZMLDSLContext * const context) {
    BOOL isEscaping = NO;
    NSInteger hierarchies = 1;
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
        if (character == XZMLElementEnd) {
            hierarchies -= 1;
            if (hierarchies == 0) {
                break;
            }
            continue;
        }
        
        // character 是元素开始字符
        if (character == XZMLElementStart) {
            // 层数增加。
            hierarchies += 1;
            continue;
        }
    } while (context->index < context->length);
}

/// 仅识别当前元素中的文本，忽略属性。
static NSData *XZMLElementDSLText(XZMLDSLContext * const context) {
    NSMutableData * const value = [NSMutableData dataWithCapacity:context->length - context->index];
    
    /// 当前循环轮次是否处于逃逸模式
    BOOL isEscaping = NO;
    /// 当前元素是否应该继续识别属性
    BOOL shouldRecognizeAttributes = YES;
    /// 子元素的层级，遇到结束字符层级递减。
    NSInteger hierarchies = 1;
    /// 记录元素属性的起点，以便在识别到属性时从结果中删除属性字符
    NSUInteger startIndex = 0;
    
    do {
        NSUInteger const index = XZMLDSLContextSearchASCII(context);
        if (context->index < index) {
            // 当前字符被跳过了，说明是非 ASCII 字符。
            const char * const bytes = context->UTF8String + context->index;
            NSUInteger   const count = index - context->index;
            [value appendBytes:bytes length:count];
        }
        context->index = index + 1; // 指向下一个字节

        char const character = context->UTF8String[index];

        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            [value appendBytes:&character length:sizeof(char)];
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }

        // character 是元素结束字符
        if (character == XZMLElementEnd) {
            hierarchies -= 1;
            if (hierarchies == 0) {
                break;
            }
            // 遇到子元素后，就不识别属性。
            shouldRecognizeAttributes = NO;
            continue;
        }
        
        // 子元素开始：character 是元素开始字符
        if (character == XZMLElementStart) {
            // 层数增加。
            hierarchies += 1;
            // 子元素继续识别属性，父元素在子元素结束时，标记不识别属性。
            shouldRecognizeAttributes = YES;
            // 记录子元素开始位置
            startIndex = value.length;
            continue;
        }

        // 属性：character 是元素属性字符
        if (shouldRecognizeAttributes && XZMLDSLAttributeCharacter(context, character)) {
            // 已识别的字符为属性，直接删除
            [value replaceBytesInRange:NSMakeRange(startIndex, value.length - startIndex) withBytes:NULL length:0];
            // 开始新的属性
            startIndex = value.length; 
            continue;
        }
        
        // character 是普通字符
        [value appendBytes:&character length:sizeof(char)];
    } while (context->index < context->length);

    return value;
}

/// 元素识别。
/// 传入的 context->index 指向当前元素开始标记之后第一个字符，
/// 本函数执行完毕 context->index 执行元素结束标记之后的第一个字符，或者指向字符串结束标志`\0`。
static void XZMLElementDSL(XZMLDSLContext * const context, NSUInteger const hierarchies) {
    // 发送元素识别开始事件
    XZMLDSLDidBeginElement(context);
    
    NSMutableData * const value = [NSMutableData dataWithCapacity:context->length - context->index];
    
    // 文本段。如果当前元素包含多个子元素，那么此值表示被子元素分隔在文本段的次序。
    NSUInteger fragment = 0;
    // 当前循环轮次是否处于逃逸模式
    BOOL isEscaping = NO;
    // 当前元素是否应该继续识别属性
    BOOL shouldRecognizeAttributes = YES;
    
    do {
        NSUInteger const index = XZMLDSLContextSearchASCII(context);
        if (context->index < index) {
            // 当前字符被跳过了，说明是非 ASCII 字符。
            const char * const bytes = context->UTF8String + context->index;
            NSUInteger   const count = index - context->index;
            [value appendBytes:bytes length:count];
        }
        // 指向下一个字符
        context->index = index + 1;
        
        // 当前字符
        char const character = context->UTF8String[index];

        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            [value appendBytes:&character length:sizeof(char)];
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }

        // character 是元素结束字符
        if (character == XZMLElementEnd) {
            break;
        }

        // character 是元素开始字符，子元素开始
        if (character == XZMLElementStart) {
            // 标记当前元素不再识别属性标记
            shouldRecognizeAttributes = NO;
            
            // 发送文本识别事件：已识别的字符作为普通文本
            NSUInteger const length = value.length;
            if (length > 0) {
                NSString * const text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                XZMLDSLFoundText(context, text, fragment++);
                [value replaceBytesInRange:NSMakeRange(0, value.length) withBytes:NULL length:0];
            }
            
            // 子元素层级超出限制，仅保留文本
            if (hierarchies > 15) {
                [value appendData:XZMLElementDSLText(context)];
                continue;
            }
            
            // 识别子元素
            XZMLElementDSL(context, hierarchies + 1);
            continue;
        }

        // character 是元素属性字符
        if (shouldRecognizeAttributes && XZMLDSLAttributeCharacter(context, character)) {
            NSString * const text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            [value replaceBytesInRange:NSMakeRange(0, value.length) withBytes:NULL length:0];
            
            // 发送属性识别事件
            XZMLReadingMode const mode = XZMLDSLFoundAttribute(context, character, text);
            
            // 仅识别文本
            if (mode == XZMLReadingModeText) {
                [value appendData:XZMLElementDSLText(context)];
                break;
            }
            
            // 终止当前元素
            if (mode == XZMLReadingModeSkip) {
                XZMLElementDSLAbort(context);
                break;
            }
            
            // 继续识别
            continue;
        }

        // character 是元素文本字符
        [value appendBytes:&character length:sizeof(char)];
    } while (context->index < context->length);

    // 发送文本识别事件：已识别的字符作为文本属性
    NSString * const text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    XZMLDSLFoundText(context, text, fragment);
    
    // 发送元素识别结束事件
    XZMLDSLDidEndElement(context);
}

void XZMLDSL(NSString *XZMLString, XZMLParser * const parser) {
    if (![XZMLString isKindOfClass:NSString.class]) {
        return;
    }
    if (XZMLString.length == 0) {
        return;
    }
    
    // 得到 UTF-8 编码的 C 字符串，以及字符串字节长度。
    const char * const str = [XZMLString cStringUsingEncoding:NSUTF8StringEncoding];
    if (str == NULL) {
        return;
    }
    const NSUInteger   len = [XZMLString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    XZMLDSLContext context = { str, len, 0, parser };
    
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
        
        if (character == XZMLElementStart) {
            // 识别元素前，处理非元素文本。
            if (start < index) {
                const char * const bytes = context.UTF8String + start;
                NSUInteger   const count = index - start;
                NSString *value = [[NSString alloc] initWithBytes:bytes length:count encoding:NSUTF8StringEncoding];
                XZMLDSLFoundText(&context, value, fragment++);
            }

            // 然后开始识别元素。
            XZMLElementDSL(&context, 0);

            // 元素识别完成后，记录位置。
            start = context.index;
        }
    }
    
    // 最后一个元素结束时，字符串后面依然有字符。
    if (start < context.index) {
        const char * const bytes = context.UTF8String + start;
        NSUInteger   const count = context.index - start;
        NSString *value = [[NSString alloc] initWithBytes:bytes length:count encoding:NSUTF8StringEncoding];
        XZMLDSLFoundText(&context, value, fragment);
    }
}
