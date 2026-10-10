//
//  XZMLDSL.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLDSL.h"
#import "XZMLParser.h"

/// XZML 元素的开始和结束标记，固定为 `<` 和 `>` 字符，不支持自定义。
#define XZMLElementStart '<'
#define XZMLElementEnd   '>'

/// XZML 解析过程的中间量。
typedef struct XZMLDSLContext {
    /// XZML 字符串 UTF-8 形式。
    const char * const UTF8String;
    /// XZML 长度，字节数。
    const NSUInteger   length;
    /// 当前指向的字节。
    NSUInteger         index;
    /// XZML 解析器。
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
static void XZMLElementDSLAbort(XZMLDSLContext * const context, char const kCurrentElementEnd) {
    BOOL isEscaping = NO;
    NSInteger hierarchies = 1;
    do {
        NSUInteger const index = XZMLDSLContextSearchASCII(context);

        // 跳过了多字节字符：若处于转义状态，被转义的正是该多字节字符，状态在此消费，
        // 否则转义会顺延到其后的 ASCII 字符（往往是 '>'）导致元素无法闭合。
        if (context->index < index) {
            isEscaping = NO;
        }

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
        if (character == kCurrentElementEnd) {
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
static NSData *XZMLElementDSLText(XZMLDSLContext * const context, char const kCurrentElementEnd) {
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
        
        // 当前字符被跳过了，说明是非 ASCII 字符。
        if (context->index < index) {
            // 被转义的字符是多字节字符本身，状态在此消费，不能顺延到其后的 ASCII 字符
            isEscaping = NO;

            const char * const bytes = context->UTF8String + context->index;
            NSUInteger   const count = index - context->index;
            [value appendBytes:bytes length:count];
            
            // 已到达字符串末尾，推进 index，避免父级重复解析剩余字节
            if (index >= context->length) {
                context->index = context->length;
                break;
            }
        }
        
        // 指向下一个字符
        context->index = index + 1;

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
        if (character == kCurrentElementEnd) {
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
static void XZMLElementDSL(XZMLDSLContext * const context, char const kCurrentElementEnd, NSUInteger const hierarchies, BOOL shouldRecognizeAttributes) {
    // 发送元素识别开始事件
    XZMLDSLDidBeginElement(context);
    
    NSMutableData * const value = [NSMutableData dataWithCapacity:context->length - context->index];
    
    // 文本段。如果当前元素包含多个子元素，那么此值表示被子元素分隔在文本段的次序。
    NSUInteger fragment = 0;
    // 当前循环轮次是否处于逃逸模式
    BOOL isEscaping = NO;
    
    do {
        NSUInteger const index = XZMLDSLContextSearchASCII(context);
        
        // 当前字符被跳过了，说明是非 ASCII 字符。
        if (context->index < index) {
            // 被转义的字符是多字节字符本身，状态在此消费，不能顺延到其后的 ASCII 字符
            isEscaping = NO;

            const char * const bytes = context->UTF8String + context->index;
            NSUInteger   const count = index - context->index;
            [value appendBytes:bytes length:count];
            
            // 已到达字符串末尾，推进 index，避免父级重复解析剩余字节
            if (index >= context->length) {
                context->index = context->length;
                break;
            }
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
        if (character == kCurrentElementEnd) {
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
                [value appendData:XZMLElementDSLText(context, XZMLElementEnd)];
                continue;
            }
            
            // 识别子元素
            XZMLElementDSL(context, XZMLElementEnd, hierarchies + 1, YES);
            continue;
        }

        // character 是元素属性字符
        if (shouldRecognizeAttributes && XZMLDSLAttributeCharacter(context, character)) {
            NSString * const text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            [value replaceBytesInRange:NSMakeRange(0, value.length) withBytes:NULL length:0];
            
            // 发送属性识别事件
            XZMLReadingMode const mode = XZMLDSLFoundAttribute(context, character, text);
            
            // 仅识别文本
            if (mode == XZMLReadingModeTextOnly) {
                [value appendData:XZMLElementDSLText(context, kCurrentElementEnd)];
                break;
            }
            
            // 终止当前元素
            if (mode == XZMLReadingModeSkipElement) {
                XZMLElementDSLAbort(context, kCurrentElementEnd);
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
    // 含未配对代理项（如 substringToIndex: 切断 emoji、服务端截断字段）时转换会失败，
    // 此时降级为纯文本输出：保住内容，放弃样式，避免整串内容静默丢失。
    const char * const UTF8String = [XZMLString cStringUsingEncoding:NSUTF8StringEncoding];
    if (UTF8String == NULL) {
        NSLog(@"[XZML] 字符串无法转换为 UTF-8 编码（可能含未配对的代理项），将按纯文本处理：%@", XZMLString);
        XZMLDSLContext context = { NULL, 0, 0, parser };
        XZMLDSLFoundText(&context, XZMLString, 0);
        return;
    }
    
    const NSUInteger UTF8Length = [XZMLString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (UTF8Length == 0) {
        return;
    }

    XZMLDSLContext context = { UTF8String, UTF8Length, 0, parser };
    
    // 将顶层当作普通元素解析：
    // 1. 顶层以字符串结束符 \0 作为结束符。
    // 2. 顶层不解析样式，样式仅对被 `<`、`>` 包围的元素生效。
    XZMLElementDSL(&context, '\0', 0, NO);
}
