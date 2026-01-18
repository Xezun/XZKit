//
//  XZObjcType.m
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import "XZObjcType.h"
#import "XZMacros.h"

/// 类型描述词的存储对象类型。
typedef NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, XZObjcType *> *> *XZObjcTypeStorage;

/// 访问类型描述词存储的函数。
static id _Nullable withStorage(id (^NS_NOESCAPE block)(XZObjcTypeStorage const storage));

/// 静态类型，只读，在 `+intialize` 方法中初始化。
static XZObjcType __unsafe_unretained *XZStaticObjcTypes[CHAR_MAX] = { NULL };

@interface XZObjcType ()
@property (class, readonly) NSMutableDictionary<NSString *, NSValue *> *typeLayouts;
+ (BOOL)size:(size_t *)size alignment:(size_t *)alignment forObjcType:(NSString *)encoding;
@end

@implementation XZObjcType

@synthesize type = _type;

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

+ (XZObjcType *)typeForType:(XZStdcType)stdcType {
    NSAssert((stdcType == (stdcType & XZStdcTypeMask)), @"");
    return XZStaticObjcTypes[(stdcType)] ?: XZStaticObjcTypes[XZStdcTypeUnknown];
}

+ (XZObjcType *)typeForEncoding:(const char *)encoding {
    return [self typeWithEncoding:encoding size:0 alignment:0 modifiers:kNilOptions];
}

+ (XZObjcType *)typeForEncoding:(const char *)encoding modifiers:(XZStdcModifiers)modifiers {
    return [self typeWithEncoding:encoding size:0 alignment:0 modifiers:modifiers];
}

+ (XZObjcType *)typeForEncoding:(const char *)encoding size:(size_t)size alignment:(size_t)alignment {
    return [self typeWithEncoding:encoding size:size alignment:alignment modifiers:kNilOptions];
}

+ (XZObjcType *)typeWithEncoding:(const char *)typeEncoding size:(size_t const)size alignment:(size_t const)alignment modifiers:(XZStdcModifiers)modifiers {
    // 非空处理
    if (typeEncoding == NULL) {
        return nil;
    }
    
    size_t typeEncodingLength = strlen(typeEncoding);
    
    // 字符串非法
    if (typeEncodingLength == 0) {
        return nil;
    }
    
    // 处理修饰符：类型编码可能会包含修饰符，比如方法参数的类型编码。
    for (size_t i = 0; i < typeEncodingLength; i++) {
        switch (typeEncoding[i]) {
            case _C_CONST: {
                modifiers |= XZStdcModifierConst;
                continue;
            }
            case _C_IN: {
                modifiers |= XZStdcModifierIn;
                continue;
            }
            case _C_INOUT: {
                modifiers |= XZStdcModifierInout;
                continue;
            }
            case _C_OUT: {
                modifiers |= XZStdcModifierOut;
                continue;
            }
            case _C_BYCOPY: {
                modifiers |= XZStdcModifierByCopy;
                continue;
            }
            case _C_BYREF: {
                modifiers |= XZStdcModifierByRef;
                continue;
            }
            case _C_ONEWAY: {
                modifiers |= XZStdcModifierOneway;
                continue;
            }
            case _C_COMPLEX: {
                modifiers |= XZStdcModifierComplex;
                continue;
            }
            case _C_ATOMIC: {
                modifiers |= XZStdcModifierAtomic;
                continue;
            }
            case _C_GNUREGISTER: {
                modifiers |= XZStdcModifierGNURegister;
                continue;
            }
            default: {
                // 只有修饰符，不是合法的编码
                if (i >= typeEncodingLength) {
                    return nil;
                }
                // 重新定位字符编码的起点
                typeEncoding = typeEncoding + i;
                typeEncodingLength -= i;
                break;
            }
        }
        break;
    }
    
    // 确定类型编码长度
    
    
    // 没有修饰符。
    if (!modifiers) {
        NSString * const key = [NSString stringWithCString:typeEncoding encoding:NSASCIIStringEncoding];
        
        XZObjcType * const type = withStorage(^id(XZObjcTypeStorage const storage) {
            return storage[key];
        });
        
        if (type) {
            return type;
        }
    }
    
    
    
    NSNumber * const key = @(modifiers);
    
    
    
    XZStdcType const stdcType = (XZStdcType)typeEncoding[0];
    
    if (modifiers == kNilOptions) {
        XZObjcType * const type = XZStaticObjcTypes[stdcType];
        if (type != NULL) {
            return type;
        }
    }
    
    NSString * _encoding  = nil;
    NSString * _name      = nil;
    size_t     _size      = 0;
    size_t     _sizeInBit = 0;
    size_t     _alignment = 0;
    NSArray  * _members   = nil;
    Class      _subtype   = Nil;
    NSArray  * _protocols = nil;
    
    switch (stdcType) {
        case XZStdcTypeUnknown:
        case XZStdcTypeChar:
        case XZStdcTypeUnsignedChar:
        case XZStdcTypeInt:
        case XZStdcTypeUnsignedInt:
        case XZStdcTypeShort:
        case XZStdcTypeUnsignedShort:
        case XZStdcTypeLongLong:
        case XZStdcTypeUnsignedLongLong:
        case XZStdcTypeLong:
        case XZStdcTypeUnsignedLong:
        case XZStdcTypeInt128:
        case XZStdcTypeUnsignedInt128:
        case XZStdcTypeFloat:
        case XZStdcTypeDouble:
        case XZStdcTypeLongDouble:
        case XZStdcTypeBool:
        case XZStdcTypeVoid:
        case XZStdcTypeString:
        case XZStdcTypeClass:
        case XZStdcTypeSelector: {
            XZObjcType * const type = XZStaticObjcTypes[stdcType];
            if (!modifiers) {
                return type;
            }
            return [[self alloc] initWithType:type modifiers:modifiers];
        }
        case XZStdcTypePointer: {
            XZObjcType * const type = XZStaticObjcTypes[XZStdcTypePointer];
            XZObjcType * const member = [XZObjcType typeForEncoding:typeEncoding + 1];
            if (member == nil) {
                return type;
            }
            NSString * const name = [NSString stringWithFormat:@"%@ pointer", member.name];
            NSString * const encoding = [[NSString alloc] initWithBytes:typeEncoding length:member.encoding.length + 1 encoding:NSUTF8StringEncoding];
            return [[self alloc] initWithType:type modifiers:modifiers name:name encoding:encoding];
        }
        case XZStdcTypeBitField: { // {Foobar=b1b2b3}
            XZObjcType * const type = XZStaticObjcTypes[XZStdcTypeBitField];
            if (typeEncodingLength == 2) {
                return type;
            }
            
            size_t sizeInBit = 0;
            // bit field 十进制
            size_t newLength = 1;
            while (newLength < typeEncodingLength) {
                const char number = typeEncoding[newLength];
                if (number >= '0' && number <= '9') {
                    sizeInBit = sizeInBit * 10 + (number - '0');
                    newLength += 1;
                    continue;
                }
                if (newLength == 1) {
                    return type;
                }
                break;
            }
            typeEncodingLength = newLength;
            
            // 从位域的编码中，只能获取占用内存的位数，而实际占用内存和对齐，跟声明位域的类型有关。
            // 比如 int a:1 占用 1 位 4 字节，long a:1 占用 1 位 8 字节。
            NSString * const encoding = [[NSString alloc] initWithBytes:typeEncoding length:typeEncodingLength encoding:NSASCIIStringEncoding];
            NSString * const name = [NSString stringWithFormat:@"%ld bits field", sizeInBit];
            size_t     const size = (sizeInBit - 1) / 8 + 1;
            size_t     const alignment = size;
            return [[self alloc] initWithType:type modifiers:modifiers name:name encoding:encoding size:size alignment:alignment sizeInBit:sizeInBit];
            break;
        }
        case XZStdcTypeArray: {
            // int[10]    => [10i]
            // int[10][2] => [10[2i]]
            if (typeEncodingLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            
            // 元素数量
            size_t count = 0;
            while (i < typeEncodingLength) {
                char const number = typeEncoding[i];
                if (number < '0' || number > '9') {
                    break;
                }
                count = count * 10 + (number - '0');
                i += 1;
            }
            if (count == 0) {
                return nil;
            }
            
            // 元素类型
            XZObjcType *member = [XZObjcType typeForEncoding:(typeEncoding + i)];
            if (member == nil) {
                return nil;
            }
            
            // 查找 encoding 结尾字符
            i += member.encoding.length; // 定位到 member 的下一个字符
            if (i >= typeEncodingLength) {
                return nil;
            }
            if (typeEncoding[i] != ']') {
                return nil;
            }
            
            _encoding  = [[NSString alloc] initWithBytes:typeEncoding length:(i + 1) encoding:NSASCIIStringEncoding];
            _name = [NSString stringWithFormat:@"%@[%ld]", member.name, (long)count];
            _size = member.size * count;
            _sizeInBit = _size * 8;
            _alignment = member.alignment;
            _members = @[member];
            break;
        }
        case XZStdcTypeVector: {
            _encoding = [NSString stringWithFormat:@"%c", (char)stdcType];
            _name = @"vector";
            _size = sizeof(void *);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(void *);
            break;
        }
        case XZStdcTypeUnion: { // (Foobar=icq)
            if (typeEncodingLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            
            // 定位到 = 字符，获取共用体名字
            do {
                if (i >= typeEncodingLength) {
                    return nil;
                }
                if (typeEncoding[i] == '=') {
                    break;
                }
                i += 1;
            } while (YES);
            _name = [[NSString alloc] initWithBytes:(typeEncoding + 1) length:(i - 1) encoding:NSASCIIStringEncoding];
            
            union Foobar { };
            _size = sizeof(union Foobar);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(union Foobar);
            
            NSMutableArray * const members = [NSMutableArray array];
            for (i += 1; i < typeEncodingLength; ) {
                if (typeEncoding[i] == ')') {
                    break;
                }
                XZObjcType *member = [XZObjcType typeForEncoding:(typeEncoding + i)];
                if (member == nil) {
                    return nil;
                }
                [members addObject:member];
                i += member.encoding.length; // 移动到下一个字符
                // 共用体对齐是成员中最大的
                _size = MAX(_size, member.size);
                _alignment = MAX(_alignment, member.alignment);
            }
            _members = members.copy;
            
            if (size > 0 && alignment > 0) {
                if (modifiers) {
                    //                    [[self alloc] initWithRaw:_encoding type:_raw modifiers:kNilOptions name:_name size:size sizeInBit:size * 8 alignment:alignment members:members subtype:Nil protocols:nil];
                } else {
                    
                }
            }
            
            _encoding = [[NSString alloc] initWithBytes:typeEncoding length:(i + 1) encoding:NSASCIIStringEncoding];
            [self size:&_size alignment:&_alignment forObjcType:_encoding];
            _sizeInBit = _size * 8;
            
            break;
        }
        case XZStdcTypeStruct: { // {name=type...}
            if (typeEncodingLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            do {
                if (i >= typeEncodingLength) {
                    return nil;
                }
                if (typeEncoding[i] == '=') {
                    break;
                }
                i += 1;
            } while (YES);
            _name = [[NSString alloc] initWithBytes:(typeEncoding + 1) length:(i - 1) encoding:NSASCIIStringEncoding];
            
            NSMutableArray * const members = [NSMutableArray array];
            for (i += 1; i < typeEncodingLength; ) {
                if (typeEncoding[i] == '}') {
                    break;
                }
                XZObjcType *member = [XZObjcType typeForEncoding:(typeEncoding + i)];
                if (member == nil) {
                    return nil;
                }
                [members addObject:member];
                i += member.encoding.length;
            }
            _members = members.copy;
            
            _encoding = [[NSString alloc] initWithBytes:typeEncoding length:(i + 1) encoding:NSASCIIStringEncoding];
            if (![self size:&_size alignment:&_alignment forObjcType:_encoding]) {
                if (members.count > 0) {
                    for (XZObjcType *member in _members) {
                        if (_size % member.alignment == 0) {
                            _size += member.size;
                        } else {
                            _size = (_size / member.alignment + 1) * member.alignment + member.size;
                        }
                        _sizeInBit = _sizeInBit + member.sizeInBit;
                        _alignment = MAX(_alignment, member.alignment);
                    }
                    size_t const delta = _size % _alignment;
                    if (delta > 0) {
                        _size += _alignment - delta;
                    }
                } else {
                    struct Foobar { };
                    _size = sizeof(struct Foobar);
                    _alignment = _Alignof(struct Foobar);
                }
            }
            _sizeInBit = _size * 8;
            
            break;
        }
        case XZStdcTypeObject: {
            // 对象类型的 type encoding 存在如下情形：
            // id                                                   => @
            // NSString *                                           => @"NSString"
            // id<UITableViewDelegate>                              => @"<UITableViewDelegate>"
            // UIView<UITableViewDataSource> *                      => @"UIView<UITableViewDataSource>"
            // id<UITableViewDataSource, UITableViewDelegate>       => @"<UITableViewDataSource><UITableViewDelegate>"
            // UIView<UITableViewDataSource, UITableViewDelegate> * => @"UIView<UITableViewDataSource><UITableViewDelegate>"
            // 所以，如果长度超 1 则表示可能包含类名。
            if (typeEncodingLength > 1) {
                if (typeEncoding[1] != '"') { // 第2个字符必须时双引号
                    typeEncodingLength = 1;
                } else if (typeEncodingLength < 4) { // 包含类名时，长度不能小于4，比如 @"A"
                    typeEncodingLength = 1;
                } else {
                    size_t newLength = 1;
                    for (size_t i = 2; i < typeEncodingLength; i++) {
                        if (typeEncoding[i] == '"') {
                            newLength = i + 1;
                            break;
                        }
                    }
                    typeEncodingLength = newLength;
                }
            }
            
            _encoding  = [[NSString alloc] initWithBytes:typeEncoding length:typeEncodingLength encoding:NSASCIIStringEncoding];
            _name = @"object";
            _size = sizeof(id);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(id);
            
            if (typeEncodingLength > 1) {
                NSRange range = [_encoding rangeOfString:@"<"];
                if (range.location == NSNotFound) {
                    NSString * const className = [_encoding substringWithRange:NSMakeRange(2, typeEncodingLength - 3)];
                    _subtype = NSClassFromString(className);
                    _name = [NSString stringWithFormat:@"%@ %@", className, _name];
                    _protocols = nil;
                } else {
                    if (range.location > 2) { // @"Name<Protocol>"
                        NSString * const className = [_encoding substringWithRange:NSMakeRange(2, (range.location + 1) - 3)];
                        _subtype = NSClassFromString(className);
                        _name = [NSString stringWithFormat:@"%@ %@", className, _name];
                    }
                    // 起点：第一个 < 符号的下一个字符。长度：总长度 - 第一个 < 左边的字符长度 - 末尾的双引号 - 末尾的 > 符号
                    NSString * const protocolString = [_encoding substringWithRange:NSMakeRange(range.location + 1, typeEncodingLength - (range.location + 1) - 1 - 1)];
                    NSArray<NSString *> * const protocolNames = [protocolString componentsSeparatedByString:@"><"];
                    NSMutableArray * const protocols = [NSMutableArray arrayWithCapacity:protocolNames.count];
                    for (NSString * const name in protocolNames) {
                        Protocol *protocol = NSProtocolFromString(name);
                        if (protocol) {
                            [protocols addObject:protocol];
                        }
                    }
                    _protocols = protocols.copy;
                }
            }
            break;
        }
        default: {
            return nil;
            break;
        }
    }
    
    return withStorage(^id(XZObjcTypeStorage const storage) {
        XZObjcType *descriptor = storage[_encoding][key];
        if (descriptor) {
            return descriptor;
        }
        descriptor = [[self alloc] initWithRaw:stdcType encoding:_encoding modifiers:modifiers name:_name size:_size sizeInBit:_sizeInBit alignment:_alignment members:_members subtype:_subtype protocols:_protocols];
        NSMutableDictionary *dictM = storage[_encoding];
        if (dictM == nil) {
            dictM = [NSMutableDictionary dictionary];
            storage[_encoding] = dictM;
        }
        dictM[key] = descriptor;
        return descriptor;
    });
}

- (instancetype)initWithRaw:(XZStdcType)raw encoding:(NSString *)encoding name:(NSString *)name size:(size_t)size sizeInBit:(size_t)sizeInBit alignment:(size_t)alignment {
    return [self initWithRaw:raw encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
}

- (instancetype)initWithType:(XZObjcType *)type modifiers:(XZStdcModifiers)modifiers {
    XZStdcType const stdcType  = type.raw;
    NSString * const encoding  = type.encoding;
    NSString * const name      = type.name;
    size_t     const size      = type.size;
    size_t     const sizeInBit = type.sizeInBit;
    size_t     const alignment = type.alignment;
    Class      const subtype   = type.subtype;
    NSArray  * const members   = type.members;
    NSArray  * const protocols = type.protocols;
    return [self initWithRaw:stdcType encoding:encoding modifiers:modifiers name:name size:size sizeInBit:sizeInBit alignment:alignment members:members subtype:subtype protocols:protocols];
}

- (instancetype)initWithType:(XZObjcType *)type modifiers:(XZStdcModifiers)modifiers name:(NSString *)name encoding:(NSString *)encoding {
    XZStdcType const stdcType  = type.raw;
    size_t     const size      = type.size;
    size_t     const sizeInBit = type.sizeInBit;
    size_t     const alignment = type.alignment;
    Class      const subtype   = type.subtype;
    NSArray  * const members   = type.members;
    NSArray  * const protocols = type.protocols;
    return [self initWithRaw:stdcType encoding:encoding modifiers:modifiers name:name size:size sizeInBit:sizeInBit alignment:alignment members:members subtype:subtype protocols:protocols];
}

- (instancetype)initWithType:(XZObjcType *)type modifiers:(XZStdcModifiers)modifiers name:(NSString *)name encoding:(NSString *)encoding size:(size_t)size alignment:(size_t)alignment sizeInBit:(size_t)sizeInBit {
    XZStdcType const stdcType  = type.raw;
    Class      const subtype   = type.subtype;
    NSArray  * const members   = type.members;
    NSArray  * const protocols = type.protocols;
    return [self initWithRaw:stdcType encoding:encoding modifiers:modifiers name:name size:size sizeInBit:sizeInBit alignment:alignment members:members subtype:subtype protocols:protocols];
}
- (instancetype)initWithRaw:(XZStdcType)stdcType encoding:(NSString *)encoding modifiers:(XZStdcModifiers)modifiers name:(NSString *)name size:(size_t)size sizeInBit:(size_t)sizeInBit alignment:(size_t)alignment members:(NSArray<XZObjcType *> *)members subtype:(Class)subtype protocols:(NSArray<Protocol *> *)protocols {
    self = [super init];
    if (self) {
        _raw = stdcType;
        _encoding = encoding.copy;
        _name     = name.copy;
        _modifiers = modifiers;
        _size = size;
        _sizeInBit = sizeInBit;
        _alignment = alignment;
        _members = members.copy;
        _subtype = subtype;
        _protocols = protocols.copy;
    }
    return self;
}

- (XZObjcType *)type {
    return XZStaticObjcTypes[_raw];
}

- (NSString *)description {
    NSString *protocols = nil;
    if (self.protocols.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.protocols enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    %@,\n", NSStringFromProtocol(obj)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        protocols = stringM;
    }
    
    NSString *members = nil;
    if (self.members.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.members enumerateObjectsUsingBlock:^(XZObjcType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@>,\n", obj, ((id)obj.subtype ?: obj.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        members = stringM;
    }
    
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: %lu, raw: %@, sizeInBit: %lu, size: %lu, alignment: %lu, subtype: %@, protocols: %@, members: %@>", NSStringFromClass(self.class), self, self.name, (unsigned long)self.raw, self.encoding, self.sizeInBit, self.size, self.alignment, self.subtype, protocols, members];
}

#pragma mark - Provider

typedef struct XZStdcTypeLayout {
    size_t size;
    size_t alignment;
} XZStdcTypeLayout;

+ (NSMutableDictionary<NSString *, NSValue *> *)typeLayouts {
    static NSMutableDictionary<NSString *, NSValue *> *_typeLayouts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _typeLayouts = [NSMutableDictionary dictionary];
    });
    return _typeLayouts;
}

+ (void)registerSize:(size_t)size alignment:(size_t)alignment forType:(const char * const)encoding {
    if (encoding == NULL) {
        return;
    }
    NSString *       const typeName   = [NSString stringWithCString:encoding encoding:NSASCIIStringEncoding];
    XZStdcTypeLayout const typeLayout = {size, alignment};
    self.typeLayouts[typeName] = [NSValue valueWithBytes:&typeLayout objCType:@encode(XZStdcTypeLayout)];
}

+ (BOOL)size:(size_t *)size alignment:(size_t *)alignment forObjcType:(NSString * const)typeName {
    XZStdcTypeLayout typeLayout = {0, 0};
    if (typeName == nil) {
        return NO;
    }
    NSValue * const value = self.typeLayouts[typeName];
    if (value == nil) {
        return NO;
    }
    [value getValue:&typeLayout];
    *size      = typeLayout.size;
    *alignment = typeLayout.alignment;
    return YES;
}

+ (void)initialize {
    if (self == [XZObjcType class]) {
        XZObjcTypeRegister(CGPoint);
        XZObjcTypeRegister(CGSize);
        XZObjcTypeRegister(CGRect);
        XZObjcTypeRegister(CGVector);
        
        XZObjcTypeRegister(UIEdgeInsets);
        XZObjcTypeRegister(UIOffset);
        
        XZObjcTypeRegister(NSDirectionalEdgeInsets);
        XZObjcTypeRegister(NSRange);
        
        XZObjcTypeRegister(CGAffineTransform);
        
#define XZRegisterStaticType(type) { \
    const char * const typeEncoding = @encode(type);\
    XZStdcType const stdcType = (XZStdcType)typeEncoding[0]; \
    NSString * const encoding = [NSString stringWithFormat:@"%s", typeEncoding]; \
    NSString * const name = @"" # type; \
    size_t const size = sizeof(type); \
    size_t const sizeInBit = size * 8; \
    size_t const alignment = _Alignof(type); \
    XZStaticObjcTypes[stdcType] = (__bridge id)(__bridge_retained CFTypeRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];\
}
        {
            typedef void (unknown)(void);
            XZRegisterStaticType(unknown);
        }
        XZRegisterStaticType(char);
        XZRegisterStaticType(unsigned char);
        XZRegisterStaticType(int);
        XZRegisterStaticType(unsigned int);
        XZRegisterStaticType(short);
        XZRegisterStaticType(unsigned short);
        XZRegisterStaticType(long);
        XZRegisterStaticType(unsigned long);
        { // int_128
            XZStdcType const stdcType = (XZStdcType)_C_INT128;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_INT128];
            NSString * const name = @"int 128";
            size_t const size = __SIZEOF_INT128__;
            size_t const sizeInBit = size * 8;
            size_t const alignment = size;
            XZStaticObjcTypes[_C_INT128] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
        { // unsigned int_128
            XZStdcType const stdcType = (XZStdcType)_C_UINT128;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_UINT128];
            NSString * const name = @"unsigned int 128";
            size_t const size = __SIZEOF_INT128__;
            size_t const sizeInBit = size * 8;
            size_t const alignment = size;
            XZStaticObjcTypes[_C_UINT128] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
#if XZ_TYPE_LLONG_IS_LONG
        { // long long
            XZStdcType const stdcType = (XZStdcType)_C_LNG_LNG;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_LNG_LNG];
            NSString * const name = @"long long";
            size_t const size = sizeof(long long);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(long long);
            XZStaticObjcTypes[_C_LNG_LNG] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
        { // unsigned long long
            XZStdcType const stdcType = (XZStdcType)_C_ULNG_LNG;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_ULNG_LNG];
            NSString * const name = @"unsigned long long";
            size_t const size = sizeof(unsigned long long);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(unsigned long long);
            XZStaticObjcTypes[_C_ULNG_LNG] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
#else
        XZRegisterStaticType(long long);
        XZRegisterStaticType(unsigned long long);
#endif
        XZRegisterStaticType(float);
        XZRegisterStaticType(double);
#if TYPE_LONGDOUBLE_IS_DOUBLE
        { // long double
            XZStdcType const stdcType = (XZStdcType)_C_LNG_DBL;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_LNG_DBL];
            NSString * const name = @"long double";
            size_t const size = sizeof(long double);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(long double);
            XZStaticObjcTypes[_C_LNG_DBL] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
#else
        XZRegisterStaticType(long double);
#endif
        XZRegisterStaticType(bool);
        XZRegisterStaticType(void);
        { // c string
            typedef char *string;
            XZRegisterStaticType(string);
        }
        XZRegisterStaticType(SEL);
        XZRegisterStaticType(void *);
        { // pointer XZStdcTypePointer
            XZStdcType const stdcType = (XZStdcType)_C_PTR;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_PTR];
            NSString * const name = @"pointer";
            size_t const size = sizeof(void *);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(void *);
            XZStaticObjcTypes[_C_PTR] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
        { // c array
            XZStdcType const stdcType = (XZStdcType)_C_ARY_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_ARY_B, _C_ARY_E];
            NSString * const name = @"array";
            size_t const size = sizeof(void *);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(void *);
            XZStaticObjcTypes[_C_ARY_B] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
        { // c++ vector
            XZStdcType const stdcType = (XZStdcType)_C_VECTOR;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_VECTOR];
            NSString * const name = @"vector";
            size_t const size = sizeof(void *);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(void *);
            XZStaticObjcTypes[_C_VECTOR] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
        { // bit field
            XZStdcType const stdcType = (XZStdcType)_C_BFLD;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_BFLD];
            NSString * const name = @"bit field";
            size_t const size = 1;
            size_t const sizeInBit = 1;
            size_t const alignment = _Alignof(int);
            XZStaticObjcTypes[_C_VECTOR] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
        { // union
            typedef union Empty { } Empty;
            XZStdcType const stdcType = (XZStdcType)_C_UNION_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_UNION_B, _C_UNION_E];
            NSString * const name = @"union";
            size_t const size = sizeof(Empty);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(Empty);
            XZStaticObjcTypes[_C_UNION_B] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
        { // union
            typedef struct Empty { } Empty;
            XZStdcType const stdcType = (XZStdcType)_C_STRUCT_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_STRUCT_B, _C_STRUCT_E];
            NSString * const name = @"struct";
            size_t const size = sizeof(Empty);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(Empty);
            XZStaticObjcTypes[_C_STRUCT_B] = (__bridge id)(__bridge_retained CFStringRef)[[XZObjcType alloc] initWithRaw:stdcType encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
        }
        XZRegisterStaticType(Class);
        XZRegisterStaticType(id);
#undef XZRegisterStaticType
    }
}

@end



static id _Nullable withStorage(id (^NS_NOESCAPE block)(XZObjcTypeStorage const storage)) {
    static dispatch_semaphore_t _lock;
    static XZObjcTypeStorage _storage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = dispatch_semaphore_create(1);
        _storage = [NSMutableDictionary dictionary];
    });
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id const value = block(_storage);
    dispatch_semaphore_signal(_lock);
    
    return value;
}
