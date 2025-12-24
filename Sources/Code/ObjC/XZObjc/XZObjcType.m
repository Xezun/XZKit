//
//  XZObjcType.m
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import "XZObjcType.h"
#import "XZMacros.h"

/// 类型描述词的存储对象类型。
typedef NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, XZObjcType *> *> *XZStdcTypeStorage;
/// 访问类型描述词存储的函数。
static id _Nullable XZObjcStorage(id (^NS_NOESCAPE block)(XZStdcTypeStorage const storage)) {
    static dispatch_semaphore_t _lock;
    static XZStdcTypeStorage _storage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = dispatch_semaphore_create(1);
        _storage = [NSMutableDictionary dictionary];
    });
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id value = block(_storage);
    dispatch_semaphore_signal(_lock);
    
    return value;
}

static XZObjcType __unsafe_unretained *XZStaticOBJCTypes[CHAR_MAX] = { NULL };

@interface XZObjcType ()
@property (class, readonly) NSMutableDictionary<NSString *, NSValue *> *typeLayouts;
+ (BOOL)size:(size_t *)size alignment:(size_t *)alignment forObjcType:(NSString *)encoding;
@end

@implementation XZObjcType

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
        
        XZObjcType *type = XZStaticOBJCTypes[0];
        type.raw;
    }
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

+ (XZObjcType *)typeWithEncoding:(const char *)encoding {
    return [self typeWithEncoding:encoding size:0 alignment:0 modifiers:kNilOptions];
}

+ (XZObjcType *)typeWithEncoding:(const char *)encoding modifiers:(XZStdcModifiers)modifiers {
    return [self typeWithEncoding:encoding size:0 alignment:0 modifiers:modifiers];
}

+ (XZObjcType *)typeWithEncoding:(const char *)encoding size:(size_t)size alignment:(size_t)alignment {
    return [self typeWithEncoding:encoding size:size alignment:alignment modifiers:kNilOptions];
}

+ (XZObjcType *)typeWithEncoding:(const char *)encoding size:(size_t const)size alignment:(size_t const)alignment modifiers:(XZStdcModifiers)modifiers {
    // 非空处理
    if (encoding == NULL) {
        return nil;
    }
    
    size_t encodingLength = strlen(encoding);
    
    // 字符串非法
    if (encodingLength == 0) {
        return nil;
    }
    
    // 处理修饰符，类型编码可能会包含修饰符，比如方法参数的类型编码。
    for (size_t i = 0; i < encodingLength; i++) {
        switch (encoding[i]) {
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
                if (i >= encodingLength) {
                    return nil;
                }
                // 重新定位字符编码的起点
                encoding = encoding + i;
                encodingLength -= i;
                break;
            }
        }
        break;
    }
    
    NSNumber * const key = @(modifiers);
    
    { // 查询是否已创建。
        NSString *encodingKey = [NSString stringWithCString:encoding encoding:NSASCIIStringEncoding];
        
        XZObjcType * const descriptor = XZObjcStorage(^id(XZStdcTypeStorage const storage) {
            return storage[encodingKey][key];
        });
        
        if (descriptor) {
            return descriptor;
        }
    }
    
    XZStdcType const _raw = encoding[0];
    
    if (modifiers == kNilOptions) {
        XZObjcType * const type = XZStaticOBJCTypes[_raw];
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
    
    switch (_raw) {
        case XZStdcTypeUnknown: {
            typedef void (Foobar)(void);
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"unknown";
            _size = sizeof(Foobar);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(Foobar);
            break;
        }
        case XZStdcTypeChar: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"char";
            _size = sizeof(char);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(char);
            break;
        }
        case XZStdcTypeUnsignedChar: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"unsigned char";
            _size = sizeof(unsigned char);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned char);
            break;
        }
        case XZStdcTypeInt: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"int";
            _size = sizeof(int);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(int);
            break;
        }
        case XZStdcTypeUnsignedInt: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"unsigned int";
            _size = sizeof(unsigned int);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned int);
            break;
        }
        case XZStdcTypeShort: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"short";
            _size = sizeof(short);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(short);
            break;
        }
        case XZStdcTypeUnsignedShort: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"unsigned short";
            _size = sizeof(unsigned short);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned short);
            break;
        }
        case XZStdcTypeLongLong: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"long long";
            _size = sizeof(long long);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(long long);
            break;
        }
        case XZStdcTypeUnsignedLongLong: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"unsigned long long";
            _size = sizeof(unsigned long long);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned long long);
            break;
        }
        case XZStdcTypeLong: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"long";
            _size = sizeof(long);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(long);
            break;
        }
        case XZStdcTypeUnsignedLong: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"unsigned long";
            _size = sizeof(unsigned long);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned long);
            break;
        }
        case XZStdcTypeInt128: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"integer 128";
            _size = sizeof(UInt64) * 2;
            _sizeInBit = _size * 8;
            _alignment = _size;
            break;
        }
        case XZStdcTypeUnsignedInt128: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"unsigned integer 128";
            _size = sizeof(UInt64) * 2;
            _sizeInBit = _size * 8;
            _alignment = _size;
            break;
        }
        case XZStdcTypeFloat: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"float";
            _size = sizeof(float);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(float);
            break;
        }
        case XZStdcTypeDouble: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"double";
            _size = sizeof(double);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(double);
            break;
        }
        case XZStdcTypeLongDouble: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"long double";
            _size = sizeof(long double);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(long double);
            break;
        }
        case XZStdcTypeBool: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"bool";
            _size = sizeof(bool);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(bool);
            break;
        }
        case XZStdcTypeVoid: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"void";
            _size = sizeof(void);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(void);
            break;
        }
        case XZStdcTypeString: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"char *";
            _size = sizeof(char *);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(char *);
            break;
        }
        case XZStdcTypeClass: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"class";
            _size = sizeof(Class);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(Class);
            break;
        }
        case XZStdcTypeSEL: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"selector";
            _size = sizeof(SEL);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(SEL);
            break;
        }
        case XZStdcTypePointer: {
            XZObjcType *member = [XZObjcType typeWithEncoding:encoding + 1];
            if (member == nil) {
                return nil;
            }
            NSUInteger const length = 1 + member.encoding.length;
            _encoding  = [[NSString alloc] initWithBytes:encoding length:length encoding:(NSASCIIStringEncoding)];
            _name = [NSString stringWithFormat:@"%@ *", member.name];
            _size = sizeof(void *);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(void *);
            _members   = @[member];
            break;
        }
        case XZStdcTypeBitField: { // {Foobar=b1b2b3}
            if (encodingLength < 2) {
                return nil;
            }
            
            size_t newLength = 1;
            while (newLength < encodingLength) {
                const char number = encoding[newLength];
                if (number >= '0' && number <= '9') {
                    _sizeInBit = _sizeInBit * 10 + (number - '0');
                    newLength += 1;
                    continue;
                }
                if (newLength == 1) {
                    return nil;
                }
                break;
            }
            encodingLength = newLength;
            
            // 从位域的编码中，只能获取占用内存的位数，而实际占用内存和对齐，跟声明位域的类型有关。
            // 比如 int a:1 占用 1 位 4 字节，long a:1 占用 1 位 8 字节。
            
            _encoding  = [[NSString alloc] initWithBytes:encoding length:encodingLength encoding:NSASCIIStringEncoding];
            _name = [NSString stringWithFormat:@"%ld bit field", (long)_sizeInBit];
            _size = (_sizeInBit - 1) / 8 + 1;
            _alignment = _size;
            break;
        }
        case XZStdcTypeArray: {
            // int[10]    => [10i]
            // int[10][2] => [10[2i]]
            if (encodingLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            
            // 元素数量
            size_t count = 0;
            while (i < encodingLength) {
                char const number = encoding[i];
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
            XZObjcType *member = [XZObjcType typeWithEncoding:(encoding + i)];
            if (member == nil) {
                return nil;
            }
            
            // 查找 encoding 结尾字符
            i += member.encoding.length; // 定位到 member 的下一个字符
            if (i >= encodingLength) {
                return nil;
            }
            if (encoding[i] != ']') {
                return nil;
            }
            
            _encoding  = [[NSString alloc] initWithBytes:encoding length:(i + 1) encoding:NSASCIIStringEncoding];
            _name = [NSString stringWithFormat:@"%@[%ld]", member.name, (long)count];
            _size = member.size * count;
            _sizeInBit = _size * 8;
            _alignment = member.alignment;
            _members = @[member];
            break;
        }
        case XZStdcTypeVector: {
            _encoding = [NSString stringWithFormat:@"%c", (char)_raw];
            _name = @"vector";
            _size = sizeof(void *);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(void *);
            break;
        }
        case XZStdcTypeUnion: { // (Foobar=icq)
            if (encodingLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            
            // 定位到 = 字符，获取共用体名字
            do {
                if (i >= encodingLength) {
                    return nil;
                }
                if (encoding[i] == '=') {
                    break;
                }
                i += 1;
            } while (YES);
            _name = [[NSString alloc] initWithBytes:(encoding + 1) length:(i - 1) encoding:NSASCIIStringEncoding];
            
            union Foobar { };
            _size = sizeof(union Foobar);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(union Foobar);
            
            NSMutableArray * const members = [NSMutableArray array];
            for (i += 1; i < encodingLength; ) {
                if (encoding[i] == ')') {
                    break;
                }
                XZObjcType *member = [XZObjcType typeWithEncoding:(encoding + i)];
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
            
            _encoding = [[NSString alloc] initWithBytes:encoding length:(i + 1) encoding:NSASCIIStringEncoding];
            [self size:&_size alignment:&_alignment forObjcType:_encoding];
            _sizeInBit = _size * 8;
            
            break;
        }
        case XZStdcTypeStruct: { // {name=type...}
            if (encodingLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            do {
                if (i >= encodingLength) {
                    return nil;
                }
                if (encoding[i] == '=') {
                    break;
                }
                i += 1;
            } while (YES);
            _name = [[NSString alloc] initWithBytes:(encoding + 1) length:(i - 1) encoding:NSASCIIStringEncoding];
            
            NSMutableArray * const members = [NSMutableArray array];
            for (i += 1; i < encodingLength; ) {
                if (encoding[i] == '}') {
                    break;
                }
                XZObjcType *member = [XZObjcType typeWithEncoding:(encoding + i)];
                if (member == nil) {
                    return nil;
                }
                [members addObject:member];
                i += member.encoding.length;
            }
            _members = members.copy;
            
            _encoding = [[NSString alloc] initWithBytes:encoding length:(i + 1) encoding:NSASCIIStringEncoding];
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
            if (encodingLength > 1) {
                if (encoding[1] != '"') { // 第2个字符必须时双引号
                    encodingLength = 1;
                } else if (encodingLength < 4) { // 包含类名时，长度不能小于4，比如 @"A"
                    encodingLength = 1;
                } else {
                    size_t newLength = 1;
                    for (size_t i = 2; i < encodingLength; i++) {
                        if (encoding[i] == '"') {
                            newLength = i + 1;
                            break;
                        }
                    }
                    encodingLength = newLength;
                }
            }
            
            _encoding  = [[NSString alloc] initWithBytes:encoding length:encodingLength encoding:NSASCIIStringEncoding];
            _name = @"object";
            _size = sizeof(id);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(id);
            
            if (encodingLength > 1) {
                NSRange range = [_encoding rangeOfString:@"<"];
                if (range.location == NSNotFound) {
                    NSString * const className = [_encoding substringWithRange:NSMakeRange(2, encodingLength - 3)];
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
                    NSString * const protocolString = [_encoding substringWithRange:NSMakeRange(range.location + 1, encodingLength - (range.location + 1) - 1 - 1)];
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
    
    return XZObjcStorage(^id(XZStdcTypeStorage const storage) {
        XZObjcType *descriptor = storage[_encoding][key];
        if (descriptor) {
            return descriptor;
        }
        descriptor = [[self alloc] initWithRaw:_raw encoding:_encoding modifiers:modifiers name:_name size:_size sizeInBit:_sizeInBit alignment:_alignment members:_members subtype:_subtype protocols:_protocols];
        NSMutableDictionary *dictM = storage[_encoding];
        if (dictM == nil) {
            dictM = [NSMutableDictionary dictionary];
            storage[_encoding] = dictM;
        }
        dictM[key] = descriptor;
        return descriptor;
    });
}

- (instancetype)initWithRaw:(XZStdcType)raw encoding:(NSString *)encoding modifiers:(XZStdcModifiers)modifiers name:(NSString *)name size:(size_t)size sizeInBit:(size_t)sizeInBit alignment:(size_t)alignment members:(NSArray<XZObjcType *> *)members subtype:(Class)subtype protocols:(NSArray<Protocol *> *)protocols {
    self = [super init];
    if (self) {
        _encoding = encoding;
        _raw = raw;
        _name = name;
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
    return self;
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

@end



