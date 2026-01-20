//
//  XZObjcType.m
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import "XZObjcType.h"
#import "XZMacros.h"

/// 访问类型描述词存储的函数。
static id _Nullable withStorage(id (^NS_NOESCAPE block)(NSMutableDictionary * const storage));

@interface XZBasicObjcType : XZObjcType {
    @package
    XZStdcType _raw;
    NSString * _encoding;
    NSInteger  _size;
    NSInteger  _sizeInBit;
    NSInteger  _alignment;
}
@end

static XZBasicObjcType __unsafe_unretained *_basicTypes[CHAR_MAX] = { NULL };

@interface XZAdvanceObjcType : XZObjcType {
    Class _subtype;
    NSArray<XZObjcType *> *_members;
    NSArray<XZObjcType *> *_protocols;
}

- (instancetype)initWithType:(XZBasicObjcType *)type modifiers:(XZStdcModifiers)modifiers;
- (instancetype)initWithType:(XZBasicObjcType *)type name:(NSString *)name encoding:(NSString *)encoding modifiers:(XZStdcModifiers)modifiers;
- (instancetype)initWithType:(XZBasicObjcType *)type name:(NSString *)name encoding:(NSString *)encoding size:(size_t)size alignment:(size_t)alignment sizeInBit:(size_t)sizeInBit modifiers:(XZStdcModifiers)modifiers;
- (instancetype)initWithType:(XZBasicObjcType *)type name:(NSString *)name encoding:(NSString *)encoding size:(size_t)size alignment:(size_t)alignment sizeInBit:(size_t)sizeInBit modifiers:(XZStdcModifiers)modifiers members:(NSArray *)members;
@end

@interface XZObjcType () {
    @package
    XZBasicObjcType *_type;
    NSString *_name;
}
- (instancetype)initWithType:(XZBasicObjcType *)type name:(NSString *)name NS_DESIGNATED_INITIALIZER;
@property (class, readonly) NSMutableDictionary<NSString *, NSValue *> *typeLayouts;
+ (BOOL)size:(size_t *)size alignment:(size_t *)alignment forObjcType:(NSString *)encoding;
@end

@implementation XZObjcType

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

+ (XZObjcType *)typeForType:(XZStdcType)stdcType {
    NSAssert((stdcType == (stdcType & XZStdcTypeMask)), @"");
    return _basicTypes[(stdcType)] ?: _basicTypes[XZStdcTypeUnknown];
}

+ (XZObjcType *)typeForEncoding:(const char *)encoding {
    return [self typeWithEncoding:encoding size:0 alignment:0];
}

+ (XZObjcType *)typeWithEncoding:(const char *)encoding size:(size_t const)size alignment:(size_t const)alignment {
    if (encoding == NULL) {
        return nil;
    }
    
    NSInteger const encodingLength = strlen(encoding);
    
    if (encodingLength == 0) {
        return nil;
    }
    
    const char *typeEncoding = encoding;
    NSInteger typeEncodingStart = 0;
    NSInteger typeEncodingLength = 0;
    
    XZStdcModifiers modifiers = kNilOptions;
    
    // 处理修饰符：类型编码可能会包含修饰符，比如方法参数的类型编码。
    for (NSInteger i = 0; i < encodingLength; i++) {
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
    
    // 基本类型：任何类型都对应一个基本类型。
    XZStdcType const stdcType = (XZStdcType)typeEncoding[0];
    XZBasicObjcType * const basicType = _basicTypes[stdcType];
    if (!basicType) {
        return nil;
    }
    
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
        case XZStdcTypeSelector:
        case XZStdcTypeVector: {
            if (modifiers) {
                NSString *encodingString = [NSString alloc] initWithBytes:encoding length:<#(NSUInteger)#> encoding:<#(NSStringEncoding)#>
                return [[XZAdvanceObjcType alloc] initWithType:basicType name:basicType.name encoding: modifiers:modifiers];
            }
            return basicType;
        }
        case XZStdcTypePointer: {
            XZObjcType * const member = [XZObjcType typeForEncoding:typeEncoding + 1 size:size alignment:alignment];
            if (member == nil) {
                return nil;
            }
            NSString * const name = [NSString stringWithFormat:@"%@ *", member.name];
            NSString * const encoding = [[NSString alloc] initWithBytes:typeEncoding length:member.encoding.length + 1 encoding:NSUTF8StringEncoding];
            return [[XZAdvanceObjcType alloc] initWithType:basicType name:name encoding:encoding modifiers:modifiers];
        }
        case XZStdcTypeBitField: {
            // 位域，结构体成员。
            // struct Foobar { int a:1; int b: 22 } => {Foobar=b1b22}
            // 从位域的编码中，只能获取占用内存的位数，而实际占用内存和对齐，跟声明位域的类型有关。
            // 比如 int a:1 占用 1 位 4 字节，long a:1 占用 1 位 8 字节。
            if (typeEncodingLength < 2) {
                return nil;
            }
            
            size_t sizeInBit = 0;
            size_t newLength = 1;
            while (newLength < typeEncodingLength) {
                const char number = typeEncoding[newLength];
                // 位域编码中，是以十进制表示位域宽度的。
                if (number >= '0' && number <= '9') {
                    sizeInBit = sizeInBit * 10 + (number - '0');
                    newLength += 1;
                    continue;
                }
                // 不合法的编码
                if (newLength == 1) {
                    return nil;
                }
                break;
            }
            typeEncodingLength = newLength;
            
            NSString * const encoding = [[NSString alloc] initWithBytes:typeEncoding length:typeEncodingLength encoding:NSUTF8StringEncoding];
            NSString * const name = sizeInBit > 1 ? [NSString stringWithFormat:@"%ld bits field", sizeInBit] : @"1 bit field";
            size_t     const size = (sizeInBit - 1) / 8 + 1;
            size_t     const alignment = size;
            return [[XZAdvanceObjcType alloc] initWithType:basicType name:name encoding:encoding size:size alignment:alignment sizeInBit:sizeInBit modifiers:modifiers];
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
            XZObjcType *member = [XZObjcType typeForEncoding:(typeEncoding + i) size:size alignment:alignment];
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
            
            NSString * const encoding  = [[NSString alloc] initWithBytes:typeEncoding length:(i + 1) encoding:NSUTF8StringEncoding];
            NSString * const name = [NSString stringWithFormat:@"%@[%ld]", member.name, (long)count];
            NSInteger const size = member.size * count;
            NSInteger const sizeInBit = size * 8;
            NSInteger const alignment = member.alignment;
            NSArray * const members = @[member];
            return [[XZAdvanceObjcType alloc] initWithType:basicType name:name encoding:encoding size:size alignment:alignment sizeInBit:sizeInBit modifiers:modifiers members:members];
        }
        case XZStdcTypeUnion: {
            // (Foobar=icq)
            if (typeEncodingLength < 4) {
                return nil;
            }
            
            size_t _index = 1;
            
            // 定位到 = 字符，获取共用体名字
            do {
                if (_index >= typeEncodingLength) {
                    return nil;
                }
                if (typeEncoding[_index] == '=') {
                    break;
                }
                _index += 1;
            } while (YES);
            NSString * const _name = [[NSString alloc] initWithBytes:(typeEncoding + 1) length:(_index - 1) encoding:NSUTF8StringEncoding];
            
            NSInteger _size = basicType.size;
            NSInteger _sizeInBit = _size * 8;
            NSInteger _alignment = basicType.alignment;
            
            NSMutableArray * const _members = [NSMutableArray array];
            while (YES) {
                _index += 1;
                // 未匹配到结尾，编码不合法
                if (_index >= typeEncodingLength) {
                    return nil;
                }
                // 匹配结尾
                if (typeEncoding[_index] == ')') {
                    break;
                }
                // 匹配成员
                XZObjcType *member = [XZObjcType typeForEncoding:(typeEncoding + _index) size:size alignment:alignment];
                if (member == nil) {
                    return nil;
                }
                [_members addObject:member];
                
                // 共用体对齐是成员中最大的
                _size = MAX(_size, member.size);
                _alignment = MAX(_alignment, member.alignment);
                
                // 移动到下一个字符
                _index += member.encoding.length;
            }
            
            NSString * const _encoding = [[NSString alloc] initWithBytes:typeEncoding length:(_index + 1) encoding:NSUTF8StringEncoding];
            return [[XZAdvanceObjcType alloc] initWithType:basicType name:_name encoding:_encoding size:size alignment:alignment sizeInBit:_sizeInBit modifiers:modifiers members:_members];
        }
        case XZStdcTypeStruct: {
            // {name=type...}
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
            NSString * const name = [[NSString alloc] initWithBytes:(typeEncoding + 1) length:(i - 1) encoding:NSUTF8StringEncoding];
            
            NSMutableArray * const members = [NSMutableArray array];
            while ( YES ) {
                i += 1;
                if (typeEncoding[i] == '}') {
                    break;
                }
                XZObjcType *member = [XZObjcType typeForEncoding:(typeEncoding + i)];
                if (member == nil) {
                    return nil;
                }
                [members addObject:member];
                i += member.encoding.length;
                if (i < typeEncodingLength) {
                    continue;
                }
                return nil;
            }
            
            NSInteger _size = basicType.size;
            NSInteger _sizeInBit = basicType.sizeInBit;
            NSInteger _alignment = basicType.alignment;
            
            NSString * const encoding = [[NSString alloc] initWithBytes:typeEncoding length:(i + 1) encoding:NSUTF8StringEncoding];
            if (members.count > 0) {
                for (XZObjcType *member in members) {
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
            
            _encoding  = [[NSString alloc] initWithBytes:typeEncoding length:typeEncodingLength encoding:NSUTF8StringEncoding];
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

- (instancetype)initWithType:(XZBasicObjcType *)type name:(NSString *)name {
    self = [super init];
    if (self) {
        _type = type;
        _name = name.copy;
    }
    return self;
}

- (NSString *)name {
    return _name;
}

- (XZObjcType *)type {
    return _type;
}

- (XZStdcType)raw {
    return _type->_raw;
}

- (XZStdcModifiers)modifiers {
    return kNilOptions;
}

- (NSString *)encoding {
    return @"";
}

- (NSInteger)size {
    return 0;
}

- (NSInteger)sizeInBit {
    return 0;
}

- (NSInteger)alignment {
    return 0;
}

- (NSArray<XZObjcType *> *)members {
    return @[];
}

- (Class)subtype {
    return Nil;
}

- (NSArray<Protocol *> *)protocols {
    return @[];
}


- (NSString *)descriptionWithIndent:(NSInteger)indent {
    NSString *padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
    
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendFormat:@"%@<%@: %p, { \n", padding, [XZObjcType class], self];
    [description appendFormat:@"%@    name: %@, \n", padding, self.name];
    [description appendFormat:@"%@    type: %@, \n", padding, self.type];
    [description appendFormat:@"%@    raw: %ld, \n", padding, self.raw];
    [description appendFormat:@"%@    sizeInBit: %ld bits, \n", padding, self.sizeInBit];
    [description appendFormat:@"%@    size: %ld bytes, \n", padding, self.size];
    [description appendFormat:@"%@    alignment: %ld bytes, \n", padding, self.alignment];
    [description appendFormat:@"%@    subtype: %@, \n", padding, self.subtype];
    
    NSString *protocols = nil;
    if (self.protocols.count > 0) {
        [description appendFormat:@"%@    protocols: [ \n", padding];
        [self.protocols enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [description appendFormat:@"%@        %@, \n", padding, NSStringFromProtocol(obj)];
        }];
        [description deleteCharactersInRange:NSMakeRange(description.length - 3, 1)];
        [description appendFormat:@"%@    ], \n", padding];
    } else {
        [description appendFormat:@"%@    protocols: [], \n", padding];
    }
    
    if (self.members.count > 0) {
        [description appendFormat:@"%@    members: [ \n", padding];
        [self.members enumerateObjectsUsingBlock:^(XZObjcType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [description appendFormat:@"%@        %@, \n", padding, [obj descriptionWithIndent:(indent + 1)]];
        }];
        [description deleteCharactersInRange:NSMakeRange(description.length - 2, 1)];
        [description appendFormat:@"%@    ], \n", padding];
    } else {
        [description appendFormat:@"%@    members: [] \n", padding];
    }
    
    [description appendFormat:@"%@}>", padding];
    return description;
}

- (NSString *)description {
    return [self descriptionWithIndent:0];
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
    NSString *       const typeName   = [NSString stringWithCString:encoding encoding:NSUTF8StringEncoding];
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

@end


@implementation XZAdvanceObjcType

- (instancetype)initWithRaw:(XZStdcType)raw encoding:(NSString *)encoding name:(NSString *)name size:(size_t)size sizeInBit:(size_t)sizeInBit alignment:(size_t)alignment {
    return [self initWithRaw:raw encoding:encoding modifiers:kNilOptions name:name size:size sizeInBit:sizeInBit alignment:alignment members:@[] subtype:Nil protocols:@[]];
}

- (instancetype)initWithType:(XZBasicObjcType *)type modifiers:(XZStdcModifiers)modifiers {
    XZStdcType const stdcType  = type->_type;
    NSString * const encoding  = type->_encoding;
    NSString * const name      = type->_name;
    size_t     const size      = type->_size;
    size_t     const sizeInBit = type->_sizeInBit;
    size_t     const alignment = type->_alignment;
    Class      const subtype   = Nil;
    NSArray  * const members   = @[];
    NSArray  * const protocols = @[];
    return [self initWithType:stdcType encoding:encoding modifiers:modifiers name:name size:size sizeInBit:sizeInBit alignment:alignment members:members subtype:subtype protocols:protocols];
}

- (instancetype)initWithType:(XZBasicObjcType *)type name:(NSString *)name encoding:(NSString *)encoding modifiers:(XZStdcModifiers)modifiers {
    XZStdcType const stdcType  = type->_raw;
    size_t     const size      = type->_size;
    size_t     const sizeInBit = type->_sizeInBit;
    size_t     const alignment = type->_alignment;
    Class      const subtype   = Nil;
    NSArray  * const members   = @[];
    NSArray  * const protocols = @[];
    return [self initWithType:stdcType encoding:encoding modifiers:modifiers name:name size:size sizeInBit:sizeInBit alignment:alignment members:members subtype:subtype protocols:protocols];
}

- (instancetype)initWithType:(XZBasicObjcType *)type name:(NSString *)name encoding:(NSString *)encoding size:(size_t)size alignment:(size_t)alignment sizeInBit:(size_t)sizeInBit modifiers:(XZStdcModifiers)modifiers {
    XZStdcType const stdcType  = type.raw;
    Class      const subtype   = type.subtype;
    NSArray  * const members   = type.members;
    NSArray  * const protocols = type.protocols;
    return [self initWithType:stdcType encoding:encoding modifiers:modifiers name:name size:size sizeInBit:sizeInBit alignment:alignment members:members subtype:subtype protocols:protocols];
}

- (instancetype)initWithType:(XZObjcType *)type encoding:(NSString *)encoding modifiers:(XZStdcModifiers)modifiers name:(NSString *)name size:(size_t)size sizeInBit:(size_t)sizeInBit alignment:(size_t)alignment members:(NSArray<XZObjcType *> *)members subtype:(Class)subtype protocols:(NSArray<Protocol *> *)protocols {
    return [super init];
//    if (self) {
//        _type = type;
//        _encoding = encoding.copy;
//        _name     = name.copy;
//        _modifiers = modifiers;
//        _size = size;
//        _sizeInBit = sizeInBit;
//        _alignment = alignment;
//        _members = members.copy;
//        _subtype = subtype;
//        _protocols = protocols.copy;
//    }
//    return self;
}

@end

static id _Nullable withStorage(id (^NS_NOESCAPE block)(NSMutableDictionary * const storage)) {
    static dispatch_semaphore_t _lock;
    static NSMutableDictionary * _storage = nil;
    
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


@implementation XZBasicObjcType

- (NSString *)encoding {
    return _encoding;
}

- (NSInteger)size {
    return _size;
}

- (NSInteger)sizeInBit {
    return _sizeInBit;
}

- (NSInteger)alignment {
    return _alignment;
}

// 基础类型都是静态类型，强引用自身。
- (instancetype)initWithType:(XZStdcType)type encoding:(NSString *)encoding name:(NSString *)name size:(size_t)size sizeInBit:(size_t)sizeInBit alignment:(size_t)alignment {
    self = [super initWithType:self name:name];
    if (self) {
        _encoding  = encoding.copy;
        _size      = size;
        _sizeInBit = sizeInBit;
        _alignment = alignment;
    }
    return self;
}

+ (void)initialize {
    if (self == [XZBasicObjcType class]) {
#define XZRegisterStaticType(type) { \
    const char * const typeEncoding = @encode(type);\
    XZStdcType const stdcType = (XZStdcType)typeEncoding[0]; \
    NSString * const encoding = [NSString stringWithFormat:@"%s", typeEncoding]; \
    NSString * const name = @"" # type; \
    size_t const size = sizeof(type); \
    size_t const sizeInBit = size * 8; \
    size_t const alignment = _Alignof(type); \
    _basicTypes[stdcType] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment]; \
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
            _basicTypes[_C_INT128] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
        { // unsigned int_128
            XZStdcType const stdcType = (XZStdcType)_C_UINT128;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_UINT128];
            NSString * const name = @"unsigned int 128";
            size_t const size = __SIZEOF_INT128__;
            size_t const sizeInBit = size * 8;
            size_t const alignment = size;
            _basicTypes[_C_UINT128] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
#if XZ_TYPE_LLONG_IS_LONG
        { // long long
            XZStdcType const stdcType = (XZStdcType)_C_LNG_LNG;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_LNG_LNG];
            NSString * const name = @"long long";
            size_t const size = sizeof(long long);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(long long);
            _basicTypes[_C_LNG_LNG] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
        { // unsigned long long
            XZStdcType const stdcType = (XZStdcType)_C_ULNG_LNG;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_ULNG_LNG];
            NSString * const name = @"unsigned long long";
            size_t const size = sizeof(unsigned long long);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(unsigned long long);
            _basicTypes[_C_ULNG_LNG] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
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
            _basicTypes[_C_LNG_DBL] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
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
        { // pointer
            XZStdcType const stdcType = (XZStdcType)_C_PTR;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_PTR];
            NSString * const name = @"pointer";
            size_t const size = sizeof(void *);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(void *);
            _basicTypes[_C_PTR] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
        { // c array
            XZStdcType const stdcType = (XZStdcType)_C_ARY_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_ARY_B, _C_ARY_E];
            NSString * const name = @"array";
            size_t const size = sizeof(void *);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(void *);
            _basicTypes[_C_ARY_B] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
        { // c++ vector
            XZStdcType const stdcType = (XZStdcType)_C_VECTOR;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_VECTOR];
            NSString * const name = @"vector";
            size_t const size = sizeof(void *);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(void *);
            _basicTypes[_C_VECTOR] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
        { // bit field
            XZStdcType const stdcType = (XZStdcType)_C_BFLD;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_BFLD];
            NSString * const name = @"bit field";
            size_t const size = 1;
            size_t const sizeInBit = 1;
            size_t const alignment = _Alignof(int);
            _basicTypes[_C_VECTOR] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
        { // union
            typedef union Empty { } Empty;
            XZStdcType const stdcType = (XZStdcType)_C_UNION_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_UNION_B, _C_UNION_E];
            NSString * const name = @"union";
            size_t const size = sizeof(Empty);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(Empty);
            _basicTypes[_C_UNION_B] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
        { // union
            typedef struct Empty { } Empty;
            XZStdcType const stdcType = (XZStdcType)_C_STRUCT_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_STRUCT_B, _C_STRUCT_E];
            NSString * const name = @"struct";
            size_t const size = sizeof(Empty);
            size_t const sizeInBit = size * 8;
            size_t const alignment = _Alignof(Empty);
            _basicTypes[_C_STRUCT_B] = [[XZBasicObjcType alloc] initWithType:stdcType encoding:encoding name:name size:size sizeInBit:sizeInBit alignment:alignment];
        }
        XZRegisterStaticType(Class);
        XZRegisterStaticType(id);
#undef XZRegisterStaticType
        
        XZObjcTypeRegister(CGPoint);
        XZObjcTypeRegister(CGSize);
        XZObjcTypeRegister(CGRect);
        XZObjcTypeRegister(CGVector);
        
        XZObjcTypeRegister(UIEdgeInsets);
        XZObjcTypeRegister(UIOffset);
        
        XZObjcTypeRegister(NSDirectionalEdgeInsets);
        XZObjcTypeRegister(NSRange);
        
        XZObjcTypeRegister(CGAffineTransform);
    }
}
@end
