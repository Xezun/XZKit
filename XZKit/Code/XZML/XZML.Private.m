//
//  XZML.Private.m
//  XZML
//
//  Created by Xezun on 2020/7/20.
//  Copyright © 2020 Xezun. All rights reserved.
//

#import "XZML.Private.h"

#pragma mark - Color Parser

/// 字符是否为十六进制字符，如果是则将参数 character 值修改为其代表的十六进制的值。
static inline BOOL ConvertCharacterToHexadecimal(char *character) {
    if (*character >= '0' && *character <= '9') {
        *character = (*character - '0');
        return YES;
    }
    if (*character >= 'a' && *character <= 'f') {
        *character = (*character - 'a') + 10;
        return YES;
    }
    if (*character >= 'A' && *character <= 'F') {
        *character = (*character - 'A') + 10;
        return YES;
    }
    return NO;
}

static UIColor *UIColorFromHexadecimalValues(NSInteger const *values, NSInteger const length) {
    switch (length) {
        case 0:
            return UIColor.clearColor;
        case 1: {
            CGFloat w = (CGFloat)values[0] / 16.0;
            return [UIColor colorWithWhite:w alpha:1.0];
        }
        case 2: {
            CGFloat w = (CGFloat)values[0] / 16.0;
            CGFloat a = (CGFloat)values[1] / 16.0;
            return [UIColor colorWithWhite:w alpha:a];
        }
        case 3: {
            CGFloat r = (CGFloat)(values[0] * 16 + values[0]) / 255.0;
            CGFloat g = (CGFloat)(values[1] * 16 + values[1]) / 255.0;
            CGFloat b = (CGFloat)(values[2] * 16 + values[2]) / 255.0;
            return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        }
        case 4: {
            CGFloat r = (CGFloat)(values[0] * 16 + values[0]) / 255.0;
            CGFloat g = (CGFloat)(values[1] * 16 + values[1]) / 255.0;
            CGFloat b = (CGFloat)(values[2] * 16 + values[2]) / 255.0;
            CGFloat a = (CGFloat)(values[3] * 16 + values[3]) / 255.0;
            return [UIColor colorWithRed:r green:g blue:b alpha:a];
        }
        case 5:  {
            CGFloat r = (CGFloat)(values[0] * 16 + values[1]) / 255.0;
            CGFloat g = (CGFloat)(values[2] * 16 + values[3]) / 255.0;
            CGFloat b = (CGFloat)(values[4] * 16 + 0) / 255.0;
            return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        }
        case 6: {
            CGFloat r = (CGFloat)(values[0] * 16 + values[1]) / 255.0;
            CGFloat g = (CGFloat)(values[2] * 16 + values[3]) / 255.0;
            CGFloat b = (CGFloat)(values[4] * 16 + values[5]) / 255.0;
            return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        }
        case 7: {
            CGFloat r = (CGFloat)(values[0] * 16 + values[1]) / 255.0;
            CGFloat g = (CGFloat)(values[2] * 16 + values[3]) / 255.0;
            CGFloat b = (CGFloat)(values[4] * 16 + values[5]) / 255.0;
            CGFloat a = (CGFloat)values[6] / 16.0;
            return [UIColor colorWithRed:r green:g blue:b alpha:a];
        }
        case 8:
        default: {
            CGFloat r = (CGFloat)(values[0] * 16 + values[1]) / 255.0;
            CGFloat g = (CGFloat)(values[2] * 16 + values[3]) / 255.0;
            CGFloat b = (CGFloat)(values[4] * 16 + values[5]) / 255.0;
            CGFloat a = (CGFloat)(values[6] * 16 + values[7]) / 255.0;
            return [UIColor colorWithRed:r green:g blue:b alpha:a];
        }
    }
}

UIColor * _Nullable UIColorFromCharacters(char const *characters, NSInteger const length) {
    NSInteger values[8] = {0};
    NSInteger count = 0;
    
    for (NSInteger i = 0; i < length && count < 8; i++) {
        char character = characters[i];
        if (ConvertCharacterToHexadecimal(&character)) {
            values[count] = (NSInteger)character;
            count += 1;
        } else {
            if (count >= 3) {
                break; // 已识别到颜色值
            }
            count = 0;
        }
    }
    
    if (count == 0) {
        return nil;
    }
    
    return UIColorFromHexadecimalValues(values, count);
}



#pragma mark - Number Parser

/// 获取字符形式数值的正负。
static inline BOOL XZMLNumberPositiveParser(char const * characters, NSInteger length, NSInteger *i) {
    while (*i < length) {
        switch (characters[*i]) {
            case ' ':
            case '\t':
            case '\n':
            case '\f':
            case '\r':
            case '\v':
            case '0':
                *i += 1;
                break;
            case '-':
                *i += 1;
                return NO;
            case '+':
                *i += 1;
                return YES;
            default:
                return YES;
        }
    }
    return YES;
}

NSInteger NSIntegerFromCharacters(char const * characters, NSInteger length) {
    NSInteger i = 0;
    BOOL const positive = XZMLNumberPositiveParser(characters, length, &i);
    
    NSInteger result = 0;
    while (i < length) {
        switch (characters[i]) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                result = result * 10 + (characters[i] - '0');
                i += 1;
                break;
            case ' ': // 支持三种数字分隔符。
            case ',':
            case '_':
                i += 1;
                break;
            default:
                return positive ? result : -result;
        }
    }
    return positive ? result : -result;
}

CGFloat CGFloatFromCharacters(char const * characters, NSInteger length) {
    NSInteger i = 0;
    BOOL const positive = XZMLNumberPositiveParser(characters, length, &i);
    
    CGFloat result = 0;
    CGFloat degree = 0; // 小数位
    while (i < length) {
        switch (characters[i]) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                if (degree) {
                    result = result + (characters[i] - '0') * degree;
                    degree *= 0.1;
                } else {
                    result = result * 10 + (characters[i] - '0');
                }
                i += 1;
                break;
                
            case '.': // 第一次遇到小数点。
                if (!degree) {
                    degree = 0.1;
                    i += 1;
                    break;
                }
                
            default:
                return (positive ? result : -result);
        }
    }
    
    return (positive ? result : -result);
}


UIColor *UIColorFromXZMLContext(XZMLContext *context, NSInteger index, UIColor *defaultColor) {
    if (index == NSNotFound) {
        return UIColorFromCharacters(XZMLContextGetValue(context), XZMLContextGetValueLength(context)) ?: defaultColor;
    }
    return UIColorFromCharacters(XZMLContextGetAttribute(context, index), XZMLContextGetAttributeLength(context, index)) ?: defaultColor;
}

NSString *NSStringFromXZMLContext(XZMLContext *context, NSInteger index) {
    if (index == NSNotFound) {
        void * const bytes = (void *)XZMLContextGetValue(context);
        NSInteger length = XZMLContextGetValueLength(context);
        return [[NSString alloc] initWithBytesNoCopy:bytes length:length encoding:(NSUTF8StringEncoding) freeWhenDone:NO];
    }
    void *bytes = (void *)XZMLContextGetAttribute(context, index);
    NSInteger length = XZMLContextGetAttributeLength(context, index);
    return [[NSString alloc] initWithBytesNoCopy:bytes length:length encoding:NSUTF8StringEncoding freeWhenDone:NO];
}

#pragma mark - DXMMML

UIColor *XZMLColorParser(XZMLContext *context, UIColor *defaultColor) {
    return UIColorFromCharacters(XZMLContextGetValue(context), XZMLContextGetValueLength(context)) ?: defaultColor;
}

NSString *XZMLStringParser(XZMLContext *context) {
    if (context->srange.length == 0) {
        return nil;
    }
    return NSStringFromXZMLContext(context, NSNotFound);
}

void XZMLParserMergeString(XZMLContext *context, NSMutableAttributedString *attributedStringM, NSDictionary<NSAttributedStringKey, id> *attributes) {
    if (context->srange.length == 0) {
        return;
    }
    NSString *string = NSStringFromXZMLContext(context, NSNotFound);
    if (string == nil) {
        return;
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [attributedStringM appendAttributedString:attributedString];
}

/// 删除线
void XZMLAttributeUnderlineParser(XZMLContext *context, NSMutableDictionary<NSAttributedStringKey, id> *attributes) {
    if (context->srange.length == 0) {
        return;
    }
    if (context->attspc > 0) {
        NSUnderlineStyle style = NSIntegerFromCharacters(XZMLContextGetAttribute(context, 0), XZMLContextGetAttributeLength(context, 0));
        attributes[NSStrikethroughStyleAttributeName] = @(style);
        UIColor *color = UIColorFromXZMLContext(context, 1, UIColor.blackColor);
        attributes[NSStrikethroughColorAttributeName] = color;
    } else {
        NSUnderlineStyle const style = NSIntegerFromCharacters(XZMLContextGetValue(context), XZMLContextGetValueLength(context));
        attributes[NSStrikethroughStyleAttributeName] = @(style);
    }
}

/// 字体颜色
void XZMLAttributeForegroundColorParser(XZMLContext *context, NSMutableDictionary<NSAttributedStringKey, id> *attributes) {
    if (context->srange.length == 0) {
        return;
    }
    attributes[NSForegroundColorAttributeName] = UIColorFromXZMLContext(context, NSNotFound, attributes[NSForegroundColorAttributeName]);
}

/// 字体
void XZMLAttributeFontParser(XZMLContext *context, NSMutableDictionary<NSAttributedStringKey, id> *attributes) {
    if (context->srange.length == 0) {
        return;
    }
    if (context->attspc > 0) {
        NSString *name = NSStringFromXZMLContext(context, 0);
        CGFloat   size = CGFloatFromCharacters(XZMLContextGetAttribute(context, 1), XZMLContextGetAttributeLength(context, 1));
        attributes[NSFontAttributeName] = [UIFont fontWithName:name size:size];
    } else {
        CGFloat size = CGFloatFromCharacters(XZMLContextGetValue(context), XZMLContextGetValueLength(context));
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:size];
    }
}

/// 变星。
NSInteger XZMLAttributeStarParser(XZMLContext *context) {
    if (context->srange.length == 0) {
        return 4;
    }
    NSInteger const star = NSIntegerFromCharacters(XZMLContextGetValue(context), XZMLContextGetValueLength(context));
    return star > 0 ? star : 4;
}
