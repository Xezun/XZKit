//
//  XZRuntime.m
//  XZKit
//
//  Created by mlibai on 2016/11/30.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZRuntime.h"
#import <CoreFoundation/CoreFoundation.h>
#import <sys/time.h>
#import <objc/runtime.h>

NSTimeInterval xz_timestamp() {
    struct timeval aTime;
    gettimeofday(&aTime, NULL);
    NSTimeInterval sec = aTime.tv_sec;
    NSTimeInterval u_sec = aTime.tv_usec * 1.0e-6L;
    return (sec + u_sec);
}

void XZPrint(NSString *format, ...) {
    va_list va_list_pointer;
    va_start(va_list_pointer, format);
    XZPrintv(format, va_list_pointer);
    va_end(va_list_pointer);
}

void XZPrintv(NSString *format, va_list args) {
    fprintf(stderr, "%s\n", [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
}

#ifdef DEBUG
void xz_debug_available(void (^statements)(void)) {
    statements();
}
#endif

// 判断 iOS 版本
BOOL xz_ios_availability(CGFloat ios_version_min, CGFloat ios_version_max) {
    CGFloat version = [UIDevice currentDevice].systemVersion.floatValue;
    return (version >= ios_version_min && version <= ios_version_max);
}


void xz_objc_exchange_methods_implementations(Class class1, SEL selector1, Class class2, SEL selector2) {
    Method method1 = class_getInstanceMethod(class1, selector1);
    Method method2 = class_getInstanceMethod(class2, selector2);
    if (!class_addMethod(class1, selector1, method_getImplementation(method2), method_getTypeEncoding(method2))) {
        method_exchangeImplementations(method1, method2);
    }
}

void xz_trim(char *str, char c) {
    size_t const len = strlen(str);
    // 去尾
    for (NSInteger i = len - 1; i >= 0; i--) {
        if (str[i] == c) {
            str[i] = '\0';
        } else {
            break;
        }
    }
    // 去头
    for (size_t i = 0, first = 0; i < len; i++) {
        if (first == 0) {
            if (str[i] == c) {
                str[i] = '\0';
            } else {
                if (i == 0) {
                    break;
                }
                first = i;
                str[0] = str[i];
            }
        } else {
            str[i - first] = str[i];
            if (str[i] == '\0') {
                break;
            }
        }
    }
}

void xz_class_property_enumerator(Class aClass, void (^enumerator)(objc_property_t property_t, NSInteger index, BOOL *stop)) {
    unsigned int property_count = 0, index = 0;
    objc_property_t *property_list = class_copyPropertyList(aClass, &property_count);
    BOOL stop = NO;
    while (!stop && index < property_count) {
        enumerator(property_list[index], index, &stop);
    }
    free(property_list);
}



XZDataType XZDataTypeFromEncoding(const char *type_encoding) {
    XZDataType dataType = XZDataTypeUnknown;
    if (type_encoding != NULL) {
        switch (type_encoding[0]) {
            case '@':
                dataType = XZDataType_id;
                break;
            case '{':
                for (XZDataType type = XZDataType_CGRect; type <= XZDataType_UIOffset; type++) {
                    if (strstr(type_encoding, XZDataTypeEncoding[type]) != NULL) {
                        dataType = type;
                        break;
                    }
                }
                break;
            case 'b':
                dataType = XZDataType_bnum;
                break;
            case '^':
                dataType = XZDataType_char_v;
                break;
            case '[':
                dataType = XZDataType_array;
                break;
            case '(':
                dataType = XZDataType_union;
                break;
            case '?':
                dataType = XZDataType_func;
                break;
            default:
                for (XZDataType type = XZDataType_int; type <= XZDataType_SEL; type++) {
                    if (strcmp(type_encoding, XZDataTypeEncoding[type]) == 0) {
                        dataType = type;
                        break;
                    }
                }
                break;
        }
    }
    return dataType;
}


NSString *NSStringFromXZDataType(XZDataType dataType) {
    switch (dataType) {
        case XZDataType_char: return @"char";
        case XZDataType_int: return @"int";
        case XZDataType_short: return @"short";
        case XZDataType_long: return @"long";
        case XZDataType_long_long: return @"long long";
        case XZDataType_unsigned_char: return @"unsigned char";
        case XZDataType_unsigned_int: return @"unsigned int";
        case XZDataType_unsigned_short: return @"unsigned short";
        case XZDataType_unsigned_long: return @"unsigned long";
        case XZDataType_unsigned_long_long: return @"unsigned long long";
        case XZDataType_float: return @"float";
        case XZDataType_double: return @"double";
        case XZDataType_bool: return @"bool";
        case XZDataType_void: return @"void";
        case XZDataType_char_v: return @"char v";
        case XZDataType_id: return @"id";
        case XZDataType_Class: return @"Class";
        case XZDataType_SEL: return @"SEL";
            
        case XZDataType_CGRect: return @"CGRect";
        case XZDataType_CGSize: return @"CGSize";
        case XZDataType_CGPoint: return @"CGPoint";
        case XZDataType_CGVector: return @"CGVector";
        case XZDataType_CGAffineTransform: return @"CGAffineTransform";
        case XZDataType_UIEdgeInsets: return @"UIEdgeInsets";
        case XZDataType_UIOffset: return @"UIOffset";
            
        case XZDataType_array: return @"array";
        case XZDataType_structure: return @"structure";
        case XZDataType_union: return @"union";
        case XZDataType_bnum: return @"bnum";
        case XZDataType_type_v: return @"type v";
        case XZDataType_func: return @"func";
            
        case XZDataTypeUnknown:  return @"unknown";
    }
}

const char * const XZDataTypeEncoding[XZDataTypeCount] = {
    @encode(char), // 0
    @encode(int),
    @encode(short), // 2
    @encode(long),
    @encode(long long),
    @encode(unsigned char), // 5
    @encode(unsigned int),
    @encode(unsigned short), // 7
    @encode(unsigned long),
    @encode(unsigned long long),
    @encode(float), // 10
    @encode(double),
    @encode(BOOL), // 12
    @encode(void),
    @encode(char *),
    @encode(id), // 15
    @encode(Class),
    @encode(SEL),
    
    "[type]",
    "{}",
    "()",
    "bnum",
    "^type",
    "?",
    
    // struct
    @encode(CGRect),
    @encode(CGSize),
    @encode(CGPoint),
    @encode(CGVector),
    @encode(CGAffineTransform),
    @encode(UIEdgeInsets),
    @encode(UIOffset)
};
