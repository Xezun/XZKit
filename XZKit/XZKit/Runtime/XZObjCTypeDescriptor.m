//
//  XZObjCTypeDescriptor.m
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import "XZObjCTypeDescriptor.h"
#import "XZLog.h"

typedef struct XZObjCTypeEmptyStruct {
    
} XZObjCTypeEmptyStruct;

typedef union XZObjCTypeEmptyUnion {
    
} XZObjCTypeEmptyUnion;

typedef struct XZObjCTypeProvider {
    size_t size;
    size_t alignment;
} XZObjCTypeProvider;


@interface XZObjCTypeDescriptor ()
+ (XZObjCTypeProvider)providerForType:(NSString *)name;
@end

@implementation XZObjCTypeDescriptor

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

+ (XZObjCTypeDescriptor *)descriptorWithTypeEncoding:(const char *)typeEncoding {
    NSParameterAssert(typeEncoding);
    return [[self alloc] initWithTypeEncoding:typeEncoding];
}

- (instancetype)initWithTypeEncoding:(const char * const)typeEncoding {
    self = [super init];
    if (self) {
        char const type = typeEncoding[0];
        switch (type) {
            case 'c': {
                _type = XZObjCTypeChar;
                _name = @"char";
                _size = sizeof(char);
                _sizeInBit = _size * 8;
                _encoding  = @"c";
                _alignment = _Alignof(char);
                _subtypes  = @[];
                break;
            }
            case 'i': {
                _type = XZObjCTypeInt;
                _name = @"int";
                _size = sizeof(int);
                _sizeInBit = _size * 8;
                _encoding  = @"i";
                _alignment = _Alignof(int);
                _subtypes  = @[];
                break;
            }
            case 's': {
                _type = XZObjCTypeShort;
                _name = @"short";
                _size = sizeof(short);
                _sizeInBit = _size * 8;
                _encoding  = @"s";
                _alignment = _Alignof(short);
                _subtypes  = @[];
                break;
            }
            case 'l': {
                _type = XZObjCTypeLong;
                _name = @"long";
                _size = sizeof(long);
                _sizeInBit = _size * 8;
                _encoding  = @"l";
                _alignment = _Alignof(long);
                _subtypes  = @[];
                break;
            }
            case 'q': {
                _type = XZObjCTypeLongLong;
                _name = @"long long";
                _size = sizeof(long long);
                _sizeInBit = _size * 8;
                _encoding  = @"q";
                _alignment = _Alignof(long long);
                _subtypes  = @[];
                break;
            }
            case 'C': {
                _type = XZObjCTypeUnsignedChar;
                _name = @"unsigned char";
                _size = sizeof(unsigned char);
                _sizeInBit = _size * 8;
                _encoding  = @"C";
                _alignment = _Alignof(unsigned char);
                _subtypes  = @[];
                break;
            }
            case 'I': {
                _type = XZObjCTypeUnsignedInt;
                _name = @"unsigned int";
                _size = sizeof(unsigned int);
                _sizeInBit = _size * 8;
                _encoding  = @"I";
                _alignment = _Alignof(unsigned int);
                _subtypes  = @[];
                break;
            }
            case 'S': {
                _type = XZObjCTypeUnsignedShort;
                _name = @"unsigned short";
                _size = sizeof(unsigned short);
                _sizeInBit = _size * 8;
                _encoding  = @"S";
                _alignment = _Alignof(unsigned short);
                _subtypes  = @[];
                break;
            }
            case 'L': {
                _type = XZObjCTypeUnsignedLong;
                _name = @"unsigned long";
                _size = sizeof(unsigned long);
                _sizeInBit = _size * 8;
                _encoding  = @"L";
                _alignment = _Alignof(unsigned long);
                _subtypes  = @[];
                break;
            }
            case 'Q': {
                _type = XZObjCTypeUnsignedLongLong;
                _name = @"unsigned long long";
                _size = sizeof(unsigned long long);
                _sizeInBit = _size * 8;
                _encoding  = @"Q";
                _alignment = _Alignof(unsigned long long);
                _subtypes  = @[];
                break;
            }
            case 'f': {
                _type = XZObjCTypeFloat;
                _name = @"float";
                _size = sizeof(float);
                _sizeInBit = _size * 8;
                _encoding  = @"f";
                _alignment = _Alignof(float);
                _subtypes  = @[];
                break;
            }
            case 'd': {
                _type = XZObjCTypeDouble;
                _name = @"double";
                _size = sizeof(double);
                _sizeInBit = _size * 8;
                _encoding  = @"d";
                _alignment = _Alignof(double);
                _subtypes  = @[];
                break;
            }
            case 'B': {
                _type = XZObjCTypeBool;
                _name = @"bool";
                _size = sizeof(bool);
                _sizeInBit = _size * 8;
                _encoding  = @"B";
                _alignment = _Alignof(bool);
                _subtypes  = @[];
                break;
            }
            case 'v': {
                _type = XZObjCTypeVoid;
                _name = @"void";
                _size = sizeof(void);
                _sizeInBit = _size * 8;
                _encoding  = @"v";
                _alignment = _Alignof(void);
                _subtypes  = @[];
                break;
            }
            case '*': {
                _type = XZObjCTypeString;
                _name = @"char *";
                _size = sizeof(char *);
                _sizeInBit = _size * 8;
                _encoding  = @"*";
                _alignment = _Alignof(char *);
                _subtypes  = @[];
                break;
            }
            case '@': {
                _type = XZObjCTypeObject;
                _name = @"object";
                _size = sizeof(id);
                _sizeInBit = _size * 8;
                _encoding  = @"@";
                _alignment = _Alignof(id);
                _subtypes  = @[];
                break;
            }
            case '#': {
                _type = XZObjCTypeClass;
                _name = @"Class";
                _size = sizeof(Class);
                _sizeInBit = _size * 8;
                _encoding  = @"#";
                _alignment = _Alignof(Class);
                _subtypes  = @[];
                break;
            }
            case ':': {
                _type = XZObjCTypeSEL;
                _name = @"SEL";
                _size = sizeof(SEL);
                _sizeInBit = _size * 8;
                _encoding  = @":";
                _alignment = _Alignof(SEL);
                _subtypes  = @[];
                break;
            }
            case '[': {
                _type = XZObjCTypeArray;
                
                // 数组元素的个数
                size_t count = 0;
                NSInteger i = 1;
                while (typeEncoding[i] >= '0' && typeEncoding[i] <= '9') {
                    count = count * 10 + (typeEncoding[i] - '0');
                    i += 1;
                }
                
                XZObjCTypeDescriptor *subtype = [XZObjCTypeDescriptor descriptorWithTypeEncoding:&typeEncoding[i]];
                
                _name = [NSString stringWithFormat:@"%@[%ld]", subtype.name, (long)count];
                _size = subtype.size * count;
                _sizeInBit = _size * 8;
                _encoding  = [[NSString alloc] initWithBytes:typeEncoding length:i + subtype.encoding.length + 1 encoding:(NSASCIIStringEncoding)];
                _alignment = subtype.alignment;
                _subtypes  = @[subtype];
                break;
            }
            case '{': { // {name=type...}
                _type = XZObjCTypeStruct;
                
                // 找到第一个等号
                NSInteger i = 2;
                while (typeEncoding[i++] != '='); // 执行完毕 i 定位在等号后面
                
                // 如果名字为 ? 则表示是匿名的结构体
                if (i == 3 && typeEncoding[1] == '?') {
                    _name = @"unknown";
                } else {
                    _name = [[NSString alloc] initWithBytes:&typeEncoding[1] length:i - 2 encoding:(NSASCIIStringEncoding)];
                }
                
                NSMutableArray *subtypes = [NSMutableArray array];
                
                _alignment = 1;
                while (typeEncoding[i] != '}') { // 用 while 而不 do-while 是因为可能会有"空"结构体
                    XZObjCTypeDescriptor *subtype = [XZObjCTypeDescriptor descriptorWithTypeEncoding:&typeEncoding[i]];
                    [subtypes addObject:subtype];
                    
                    // 对于结构体，默认字节对齐方式为成员中最大的那个。非默认情况需要由 provider 提供。
                    _alignment = MAX(_alignment, subtype.alignment);
                    
                    i += subtype.encoding.length;
                };
                
                _encoding = [[NSString alloc] initWithBytes:typeEncoding length:i + 1 encoding:(NSASCIIStringEncoding)];
                
                // 如果提供了自定义的 size 和 alignment 则使用自定的，否则根据默认规则计算。
                XZObjCTypeProvider const provider = [XZObjCTypeDescriptor providerForType:_name];
                if (provider.size > 0) {
                    _size = provider.size;
                    _sizeInBit = _size * 8;
                    _alignment = provider.alignment;
                } else if (subtypes.count > 0) {
                    _sizeInBit = 0;
                    size_t const alignmentInBit = _alignment * 8;
                    size_t availableBit = alignmentInBit; // 每个 alignment 中的可用位（字节）
                    for (XZObjCTypeDescriptor *subtype in subtypes) {
                        if (subtype.sizeInBit <= availableBit) {
                            // 可用位够，则放在可用位上，可用位减少
                            availableBit -= subtype.sizeInBit;
                        } else {
                            // 可用位不够，新起可用位，但是如果可用位还没使用，则不需要新起。
                            if (availableBit < alignmentInBit) {
                                _sizeInBit += availableBit;
                            }
                            // 可能占多个可用位
                            availableBit = alignmentInBit - subtype.sizeInBit % alignmentInBit;
                        }
                        _sizeInBit += subtype.sizeInBit;
                    }
                    if (availableBit < alignmentInBit) {
                        _sizeInBit += availableBit; // 最后一个对齐
                    }
                    _size = (_sizeInBit - 1) / 8 + 1;
                    XZLog(@"没有获取到类型 %@（%@） 的注册信息，请核对是否与默认值一致： size=%lu, alignment=%lu", _name, _encoding, _size, _alignment);
                } else {
                    _size = sizeof(XZObjCTypeEmptyStruct);
                    _sizeInBit = _size * 8;
                    _alignment = _Alignof(XZObjCTypeEmptyStruct);
                }
                
                _subtypes = subtypes.copy;
                break;
            }
            case '(': { // (name=type...)
                _type = XZObjCTypeUnion;
                
                NSInteger i = 2;
                while (typeEncoding[i++] != '='); // 执行完毕 i 定位在等号后面
                
                if (i == 3 && typeEncoding[1] == '?') {
                    _name = @"unknown";
                } else {
                    _name = [[NSString alloc] initWithBytes:&typeEncoding[1] length:i - 2 encoding:(NSASCIIStringEncoding)];
                }
                
                NSMutableArray *subtypes = [NSMutableArray array];
                
                _size = 0;
                _sizeInBit = 0;
                _alignment = 0;
                while (typeEncoding[i] != ')') {
                    XZObjCTypeDescriptor *subtype = [XZObjCTypeDescriptor descriptorWithTypeEncoding:&typeEncoding[i]];
                    [subtypes addObject:subtype];
                    
                    _size = MAX(_size, subtype.size);
                    _sizeInBit = MAX(_sizeInBit, subtype.sizeInBit);
                    _alignment = MAX(_alignment, subtype.alignment);
                    
                    i += subtype.encoding.length;
                };
                
                if (subtypes.count == 0) {
                    _size = sizeof(XZObjCTypeEmptyUnion);
                    _sizeInBit = _size * 8;
                    _alignment = _Alignof(XZObjCTypeEmptyUnion);
                }
                
                _encoding = [[NSString alloc] initWithBytes:typeEncoding length:i + 1 encoding:(NSASCIIStringEncoding)];
                _subtypes = subtypes.copy;
                break;
            }
            case 'b': {
                _type = XZObjCTypeBitField;
                _name = @"bit field";
                
                _sizeInBit = 0;
                NSInteger i = 1;
                while (typeEncoding[i] >= '0' && typeEncoding[i] <= '9') {
                    _sizeInBit = _sizeInBit * 10 + (typeEncoding[i] - '0');
                    i += 1;
                }
                
                _size = (_sizeInBit - 1) / 8 + 1;
                _encoding  = [[NSString alloc] initWithBytes:typeEncoding length:i encoding:(NSASCIIStringEncoding)];
                _alignment = 1;
                _subtypes  = @[];
                break;
            }
            case '^': {
                XZObjCTypeDescriptor *subtype = [XZObjCTypeDescriptor descriptorWithTypeEncoding:&typeEncoding[1]];
                _type = XZObjCTypePointer;
                _name = [NSString stringWithFormat:@"%@ *", subtype.name];
                _size = sizeof(void *);
                _sizeInBit = _size * 8;
                _encoding  = [[NSString alloc] initWithBytes:typeEncoding length:subtype.encoding.length + 1 encoding:(NSASCIIStringEncoding)];
                _alignment = _Alignof(void *);
                _subtypes  = @[subtype];
                break;
            }
            case '?': {
                _type = XZObjCTypeUnknown;
                _name = @"unknown";
                _size = sizeof(void *);
                _sizeInBit = _size * 8;
                _encoding  = @"?";
                _alignment = _Alignof(void *);
                _subtypes  = @[];
                break;
            }
            default: {
                assert(false);
                _type = XZObjCTypePointer;
                _name = @"unsupported";
                _size = sizeof(void *);
                _sizeInBit = _size * 8;
                _encoding  = [NSString stringWithFormat:@"%c", type];
                _alignment = _Alignof(void *);
                _subtypes  = @[];
                break;
            }
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@, %@, %lu, %lu>", NSStringFromClass(self.class), self.encoding, self.name, self.size, self.alignment];
}

#pragma mark - Provider

static NSMutableDictionary<NSString *, NSValue *> *_typeProviders = nil;

+ (void)setSize:(size_t)size alignment:(size_t)alignment forType:(NSString *)name {
    NSParameterAssert(name.length > 0);
    
    XZObjCTypeProvider info = {size, alignment};
    if (_typeProviders == nil) {
        _typeProviders = [NSMutableDictionary dictionary];
    }
    _typeProviders[name] = [NSValue valueWithBytes:&info objCType:@encode(XZObjCTypeProvider)];
}

+ (XZObjCTypeProvider)providerForType:(NSString *)name {
    XZObjCTypeProvider provider = {0, 0};
    [_typeProviders[name] getValue:&provider];
    return provider;
}

@end



@implementation XZObjCTypeDescriptor (XZObjCTypeProvider)

+ (void)load {
    [self setSize:sizeof(CGPoint) alignment:_Alignof(CGPoint) forType:@"CGPoint"];
    [self setSize:sizeof(CGSize) alignment:_Alignof(CGSize) forType:@"CGSize"];
    [self setSize:sizeof(CGRect) alignment:_Alignof(CGRect) forType:@"CGRect"];
    [self setSize:sizeof(CGVector) alignment:_Alignof(CGVector) forType:@"CGVector"];
    
    [self setSize:sizeof(UIEdgeInsets) alignment:_Alignof(UIEdgeInsets) forType:@"UIEdgeInsets"];
    if (@available(iOS 11.0, *)) {
        [self setSize:sizeof(NSDirectionalEdgeInsets) alignment:_Alignof(NSDirectionalEdgeInsets) forType:@"NSDirectionalEdgeInsets"];
    } else {
        // Fallback on earlier versions
    }
    [self setSize:sizeof(UIOffset) alignment:_Alignof(UIOffset) forType:@"UIOffset"];
    
    [self setSize:sizeof(NSRange) alignment:_Alignof(NSRange) forType:@"NSRange"];
    
    [self setSize:sizeof(XZEdgeInsets) alignment:_Alignof(XZEdgeInsets) forType:@"XZEdgeInsets"];
}

@end
