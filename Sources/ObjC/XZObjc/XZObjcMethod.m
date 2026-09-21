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

- (void)call:(id)this parameters:(NSArray *)parameters {
    NSMethodSignature * const signature  = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(_raw)];
    NSInvocation      * const invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    invocation.target   = this;
    invocation.selector = _selector;
    
    for (NSInteger i = 0; i < _arguments.count; i++) {
        id const value = asNonEmpty(parameters[i], (id)nil);
        
        XZObjcType * const type = _arguments[i];
        switch (type.type) {
            case XZStdcTypeUnknown: {
                void *argumentValue = NULL;
                [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeChar: {
                char argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(char)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedChar: {
                unsigned char argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned char)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeInt: {
                int argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(int)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedInt: {
                unsigned int argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned int)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeShort: {
                short argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(short)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedShort: {
                unsigned short argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned short)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeLong: {
                long argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(long)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedLong: {
                unsigned long argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned long)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeInt128: {
                SInt64 argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(SInt64)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedInt128: {
                UInt64 argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(UInt64)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeLongLong: {
                long long argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(long long)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeUnsignedLongLong: {
                unsigned long long argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned long long)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeFloat: {
                float argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(float)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeDouble: {
                double argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(double)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeLongDouble: {
                long double argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(long double)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeBool: {
                BOOL argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(BOOL)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeVoid: {
                // 不会出现此类型
                break;
            }
            case XZStdcTypeString: {
                char *argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(char *)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeSelector: {
                SEL argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(SEL)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypePointer: {
                void *argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeArray: {
                void *argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                break;
            }
            case XZStdcTypeVector: {
                void *argumentValue;
                [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                [invocation setArgument:&argumentValue atIndex:(i + 2)];
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
                        CGRect argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(CGRect)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeCGSize: {
                        CGSize argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(CGSize)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeCGPoint: {
                        CGPoint argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(CGPoint)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeCGVector: {
                        CGVector argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(CGVector)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeCGAffineTransform: {
                        CGAffineTransform argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(CGAffineTransform)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeNSDirectionalEdgeInsets: {
                        NSDirectionalEdgeInsets argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(NSDirectionalEdgeInsets)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeNSRange: {
                        NSRange argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(NSRange)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeUIEdgeInsets: {
                        UIEdgeInsets argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(UIEdgeInsets)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcStructTypeUIOffset: {
                        UIOffset argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(UIOffset)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
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
    
    [invocation invoke];
}

@end
