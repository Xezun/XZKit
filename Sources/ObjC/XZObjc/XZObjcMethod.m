//
//  XZObjcMethod.m
//  XZKit
//
//  Created by Xezun on 2025/1/26.
//

#import "XZObjcMethod.h"
#import "XZObjcType.h"
#import "XZEmpty.h"

@implementation XZObjcMethod

+ (instancetype)methodWithMethod:(Method)method {
    if (method == nil) {
        return nil;
    }

    SEL const _selector = method_getName(method);
    if (_selector == nil) {
        return nil;
    }

    const char * const encoding = method_getTypeEncoding(method);
    if (encoding == NULL) {
        return nil;
    }
    NSString * const _encoding = [NSString stringWithUTF8String:encoding];
    
    IMP const _implementation = method_getImplementation(method);
    
    XZObjcType *_type = nil;
    char * const typeEncoding = method_copyReturnType(method);
    if (typeEncoding != nil) {
        _type = [XZObjcType typeForEncoding:typeEncoding];
    } else {
        _type = [XZObjcType typeForEncoding:@encode(void)];
    }
    free(typeEncoding);
    
    unsigned int const numberOfArguments = method_getNumberOfArguments(method);
    NSMutableArray * const _arguments = [NSMutableArray arrayWithCapacity:numberOfArguments];
    for (unsigned int i = 2; i < numberOfArguments; i++) {
        char * const argument = method_copyArgumentType(method, i);
        XZObjcType * const argumentType = [XZObjcType typeForEncoding:argument];
        if (argumentType) {
            [_arguments addObject:argumentType];
        } else {
            [_arguments addObject:[XZObjcType typeForType:(XZStdcTypeUnknown)]];
        }
        free(argument);
    }

    return [[self alloc] initWithMethod:method selector:_selector implementation:_implementation arguments:_arguments type:_type encoding:_encoding];
}

- (instancetype)initWithMethod:(Method)method selector:(SEL)selector implementation:(IMP)implementation arguments:(NSArray *)arguments type:(XZObjcType *)type encoding:(NSString *)typeEncoding {
    self = [super init];
    if (self) {
        _raw = method;
        _name = NSStringFromSelector(selector);
        _type = type;
        _encoding = typeEncoding;
        _selector = selector;
        _implementation = implementation;
        _arguments = arguments.copy;
    }
    return self;
}

- (NSString *)description {
    NSString *type = self.type.name;
    
    NSString *arguments = nil;
    if (self.arguments.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"("];
        [self.arguments enumerateObjectsUsingBlock:^(XZObjcType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"%@, ", obj.name];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 2)];
        [stringM appendString:@")"];
        arguments = stringM;
    } else {
        arguments = @"()";
    }
    
    return [NSString stringWithFormat:@"<%@: %p, { \n"
            "    name: %@, \n"
            "    type: %@, \n"
            "    implementation: %p, \n"
            "    encoding: %@, \n"
            "    arguments: %@ \n"
            "}>", self.class, self, self.name, type, self.implementation, self.encoding, arguments];
}

@synthesize invocation = _invocation;

- (NSInvocation *)invocation {
    if (_invocation == nil) {
        NSMethodSignature * const signature  = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(_raw)];
        _invocation = [NSInvocation invocationWithMethodSignature:signature];
        _invocation.selector = _selector;
    }
    return _invocation;
}

- (void)call:(id)target parameters:(NSArray *)parameters {
    NSInvocation * const invocation = self.invocation;
    
    for (NSInteger i = 0; i < _arguments.count; i++) {
        id const value = asNonEmpty(parameters[i], (id)nil);
        
        // 假如属性 foobar 是 UInt32 类型。
        // @property (nonatomic) UInt32 foobar;
        // 通过 KVC 取出的 NSNumber 实际按 8 字节存储，而不是 UInt32 存储。
        // NSValue *value = [self valueForKey:@"foobar"];
        // UInt32 number = 0;
        // 按 UInt32 取值发生崩溃：Cannot get value with size 4. The type encoded as q is expected to be 8 bytes
        // [value getValue:&number size:sizeof(UInt32)];
        
        XZObjcType * const type = _arguments[i];
        switch (type.type) {
            case XZStdcTypeUnknown: {
                void *argumentValue = NULL;
                [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeChar: {
                char const argumentValue = [(NSNumber *)value charValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedChar: {
                unsigned char const argumentValue = [(NSNumber *)value unsignedCharValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeInt: {
                int const argumentValue = [(NSNumber *)value intValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedInt: {
                unsigned int const argumentValue = [(NSNumber *)value unsignedIntValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeShort: {
                short const argumentValue = [(NSNumber *)value shortValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedShort: {
                unsigned short const argumentValue = [(NSNumber *)value unsignedShortValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeLong: {
                long const argumentValue = [(NSNumber *)value longValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedLong: {
                unsigned long const argumentValue = [(NSNumber *)value unsignedLongValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeInt128: { // 暂无 Int128 类，用 long long 代替
                SInt64 const argumentValue = [(NSNumber *)value longLongValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedInt128: {
                UInt64 const argumentValue = [(NSNumber *)value unsignedLongLongValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeLongLong: {
                long long const argumentValue = [(NSNumber *)value longLongValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedLongLong: {
                unsigned long long const argumentValue = [(NSNumber *)value unsignedLongLongValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeFloat: {
                float const argumentValue = [(NSNumber *)value floatValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeDouble: {
                double const argumentValue = [(NSNumber *)value doubleValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeLongDouble: {
                long double const argumentValue = [(NSNumber *)value doubleValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeBool: {
                BOOL const argumentValue = [(NSNumber *)value boolValue];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeVoid: {
                // 不会出现此类型
                break;
            }
            case XZStdcTypeString: {
                char *argumentValue;
                [(NSValue *)value getValue:(void *)&argumentValue size:sizeof(char *)];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeSelector: {
                SEL const argumentValue = nil;
                [(NSValue *)value getValue:(void *)&argumentValue size:sizeof(SEL)];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypePointer: {
                void *argumentValue;
                [(NSValue *)value getValue:(void *)&argumentValue size:sizeof(void *)];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeArray: {
                void *argumentValue;
                [(NSValue *)value getValue:(void *)&argumentValue size:sizeof(void *)];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeVector: {
                void *argumentValue;
                [(NSValue *)value getValue:(void *)&argumentValue size:sizeof(void *)];
                [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeBitField: {
                // 不会出现此类型
                break;
            }
            case XZStdcTypeUnion: {
                NSString *reason = [NSString stringWithFormat:@"运行时不支持 union 类型，请使用 NSValue 类型：%@", type.name];
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
                break;
            }
            case XZStdcTypeStruct: {
                switch (type.structType) {
                    case XZStdcStructTypeUnknown: {
                        NSString *reason = [NSString stringWithFormat:@"运行时不支持 struct 类型，请使用 NSValue 类型：%@", type.name];
                        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
                        break;
                    }
                    case XZStdcStructTypeCGRect: {
                        CGRect const argumentValue = [(NSNumber *)value CGRectValue];
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeCGSize: {
                        CGSize const argumentValue = [(NSNumber *)value CGSizeValue];;
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeCGPoint: {
                        CGPoint const argumentValue = [(NSNumber *)value CGPointValue];;
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeCGVector: {
                        CGVector const argumentValue = [(NSNumber *)value CGVectorValue];;
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeCGAffineTransform: {
                        CGAffineTransform const argumentValue = [(NSNumber *)value CGAffineTransformValue];;
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeNSDirectionalEdgeInsets: {
                        NSDirectionalEdgeInsets const argumentValue = [(NSNumber *)value directionalEdgeInsetsValue];;
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeNSRange: {
                        NSRange const argumentValue = [(NSNumber *)value rangeValue];;
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeUIEdgeInsets: {
                        UIEdgeInsets const argumentValue = [(NSNumber *)value UIEdgeInsetsValue];;
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeUIOffset: {
                        UIOffset const argumentValue = [(NSNumber *)value UIOffsetValue];;
                        [invocation setArgument:(void *)&argumentValue atIndex:(i + 2)];
                        break;
                    }
                }
                break;
            }
            case XZStdcTypeClass:
            case XZStdcTypeObject: {
                [invocation setArgument:(void *)&value atIndex:(i + 2)];
                break;
            }
        }
    }
    
    [invocation invokeWithTarget:target];
}

@end
