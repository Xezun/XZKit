//
//  XZObjcTypeDescriptor.m
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import "XZObjcTypeDescriptor.h"
#import "XZMacro.h"

/// 类型描述词的存储对象类型。
typedef NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, XZObjcTypeDescriptor *> *> *XZObjcTypeStorage;
/// 访问类型描述词存储的函数。
static id _Nullable withStorage(id (^block)(XZObjcTypeStorage const _Nonnull storage));

@interface XZObjcTypeDescriptor ()
@property (class, readonly) NSMutableDictionary<NSString *, NSValue *> *typeLayouts;
+ (BOOL)size:(size_t *)size alignment:(size_t *)alignment forObjcType:(NSString *)objcType;
@end

@implementation XZObjcTypeDescriptor

+ (void)initialize {
    if (self == [XZObjcTypeDescriptor class]) {
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

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

+ (XZObjcTypeDescriptor *)descriptorForObjcType:(const char *)objcType {
    return [self descriptorForObjcType:objcType qualifiers:kNilOptions];
}

+ (XZObjcTypeDescriptor *)descriptorForObjcType:(const char *)objcType qualifiers:(XZObjcQualifiers)qualifiers {
    // 非空处理
    if (objcType == NULL) {
        return nil;
    }
    
    size_t objcTypeLength = strlen(objcType);
    
    // 字符串非法
    if (objcTypeLength == 0) {
        return nil;
    }
    
    // 处理修饰符，类型编码可能会包含修饰符，比如方法参数的类型编码。
    for (size_t i = 0; i < objcTypeLength; i++) {
        switch (objcType[i]) {
            case 'r': {
                qualifiers |= XZObjcQualifierConst;
                continue;
            }
            case 'n': {
                qualifiers |= XZObjcQualifierIn;
                continue;
            }
            case 'N': {
                qualifiers |= XZObjcQualifierInout;
                continue;
            }
            case 'o': {
                qualifiers |= XZObjcQualifierOut;
                continue;
            }
            case 'O': {
                qualifiers |= XZObjcQualifierByCopy;
                continue;
            }
            case 'R': {
                qualifiers |= XZObjcQualifierByRef;
                continue;
            }
            case 'V': {
                qualifiers |= XZObjcQualifierOneway;
                continue;
            }
            default: {
                // 只有修饰符，不是合法的编码
                if (i >= objcTypeLength) {
                    return nil;
                }
                // 重新定位字符编码的起点
                objcType = objcType + i;
                objcTypeLength -= i;
                break;
            }
        }
        break;
    }
    
    { // 查询是否已创建。
        NSString *encoding = [NSString stringWithCString:objcType encoding:NSASCIIStringEncoding];
        
        XZObjcTypeDescriptor * const descriptor = withStorage(^id(XZObjcTypeStorage const storage) {
            return storage[encoding][@(qualifiers)];;
        });
        
        if (descriptor) {
            return descriptor;
        }
    }
    
    NSString * _raw       = nil;
    XZObjcType _type      = XZObjcTypeUnknown;
    NSString * _name      = nil;
    size_t     _size      = 0;
    size_t     _sizeInBit = 0;
    size_t     _alignment = 0;
    NSArray  * _members   = nil;
    Class      _subtype   = Nil;
    NSArray  * _protocols = nil;
    
    switch (objcType[0]) {
        case '?': {
            typedef void (Foobar)(void);
            _raw  = @"?";
            _type = XZObjcTypeUnknown;
            _name = @"unknown";
            _size = sizeof(Foobar);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(Foobar);
            break;
        }
        case 'c': {
            _raw  = @"c";
            _type = XZObjcTypeChar;
            _name = @"char";
            _size = sizeof(char);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(char);
            break;
        }
        case 'C': {
            _raw  = @"C";
            _type = XZObjcTypeUnsignedChar;
            _name = @"unsigned char";
            _size = sizeof(unsigned char);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned char);
            break;
        }
        case 'i': {
            _raw  = @"i";
            _type = XZObjcTypeInt;
            _name = @"int";
            _size = sizeof(int);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(int);
            break;
        }
        case 'I': {
            _raw  = @"I";
            _type = XZObjcTypeUnsignedInt;
            _name = @"unsigned int";
            _size = sizeof(unsigned int);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned int);
            break;
        }
        case 's': {
            _raw  = @"s";
            _type = XZObjcTypeShort;
            _name = @"short";
            _size = sizeof(short);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(short);
            break;
        }
        case 'S': {
            _raw  = @"S";
            _type = XZObjcTypeUnsignedShort;
            _name = @"unsigned short";
            _size = sizeof(unsigned short);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned short);
            break;
        }
        case 'q': {
            _raw  = @"q";
            _type = XZObjcTypeLongLong;
            _name = @"long long";
            _size = sizeof(long long);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(long long);
            break;
        }
        case 'Q': {
            _raw  = @"Q";
            _type = XZObjcTypeUnsignedLongLong;
            _name = @"unsigned long long";
            _size = sizeof(unsigned long long);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned long long);
            break;
        }
        case 'l': {
            _raw  = @"l";
            _type = XZObjcTypeLong;
            _name = @"long";
            _size = sizeof(long);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(long);
            break;
        }
        case 'L': {
            _raw  = @"L";
            _type = XZObjcTypeUnsignedLong;
            _name = @"unsigned long";
            _size = sizeof(unsigned long);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(unsigned long);
            break;
        }
        case 'f': {
            _raw  = @"f";
            _type = XZObjcTypeFloat;
            _name = @"float";
            _size = sizeof(float);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(float);
            break;
        }
        case 'd': {
            _raw  = @"d";
            _type = XZObjcTypeDouble;
            _name = @"double";
            _size = sizeof(double);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(double);
            break;
        }
        case 'D': {
            _raw  = @"D";
            _type = XZObjcTypeLongDouble;
            _name = @"long double";
            _size = sizeof(long double);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(long double);
            break;
        }
        case 'B': {
            _raw  = @"B";
            _type = XZObjcTypeBool;
            _name = @"bool";
            _size = sizeof(bool);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(bool);
            break;
        }
        case 'v': {
            _raw  = @"v";
            _type = XZObjcTypeVoid;
            _name = @"void";
            _size = sizeof(void);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(void);
            break;
        }
        case '*': {
            _raw  = @"*";
            _type = XZObjcTypeString;
            _name = @"char *";
            _size = sizeof(char *);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(char *);
            break;
        }
        case '#': {
            _raw  = @"#";
            _type = XZObjcTypeClass;
            _name = @"class";
            _size = sizeof(Class);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(Class);
            break;
        }
        case ':': {
            _raw  = @":";
            _type = XZObjcTypeSEL;
            _name = @"selector";
            _size = sizeof(SEL);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(SEL);
            break;
        }
        case '^': {
            XZObjcTypeDescriptor *member = [XZObjcTypeDescriptor descriptorForObjcType:objcType + 1];
            if (member == nil) {
                return nil;
            }
            NSUInteger const length = 1 + member.raw.length;
            _raw  = [[NSString alloc] initWithBytes:objcType length:length encoding:(NSASCIIStringEncoding)];
            _type = XZObjcTypePointer;
            _name = [NSString stringWithFormat:@"%@ *", member.name];
            _size = sizeof(void *);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(void *);
            _members   = @[member];
            break;
        }
        case 'b': { // {Foobar=b1b2b3}
            if (objcTypeLength < 2) {
                return nil;
            }
            
            size_t newLength = 1;
            while (newLength < objcTypeLength) {
                const char number = objcType[newLength];
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
            objcTypeLength = newLength;
            
            // 从位域的编码中，只能获取占用内存的位数，而实际占用内存和对齐，跟声明位域的类型有关。
            // 比如 int a:1 占用 1 位 4 字节，long a:1 占用 1 位 8 字节。
            
            _raw  = [[NSString alloc] initWithBytes:objcType length:objcTypeLength encoding:NSASCIIStringEncoding];
            _type = XZObjcTypeBitField;
            _name = [NSString stringWithFormat:@"%ld bit field", (long)_sizeInBit];
            _size = (_sizeInBit - 1) / 8 + 1;
            _alignment = _size;
            break;
        }
        case '[': {
            // int[10]    => [10i]
            // int[10][2] => [10[2i]]
            if (objcTypeLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            
            // 元素数量
            size_t count = 0;
            while (i < objcTypeLength) {
                char const number = objcType[i];
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
            XZObjcTypeDescriptor *member = [XZObjcTypeDescriptor descriptorForObjcType:(objcType + i)];
            if (member == nil) {
                return nil;
            }
            
            // 查找 encoding 结尾字符
            i += member.raw.length; // 定位到 member 的下一个字符
            if (i >= objcTypeLength) {
                return nil;
            }
            if (objcType[i] != ']') {
                return nil;
            }
            
            _raw  = [[NSString alloc] initWithBytes:objcType length:(i + 1) encoding:NSASCIIStringEncoding];
            _type = XZObjcTypeArray;
            _name = [NSString stringWithFormat:@"%@[%ld]", member.name, (long)count];
            _size = member.size * count;
            _sizeInBit = _size * 8;
            _alignment = member.alignment;
            _members = @[member];
            break;
        }
        case '(': { // (Foobar=icq)
            if (objcTypeLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            
            // 定位到 = 字符，获取共用体名字
            do {
                if (i >= objcTypeLength) {
                    return nil;
                }
                if (objcType[i] == '=') {
                    break;
                }
                i += 1;
            } while (YES);
            _name = [[NSString alloc] initWithBytes:(objcType + 1) length:(i - 1) encoding:NSASCIIStringEncoding];
            
            union Foobar { };
            _size = sizeof(union Foobar);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(union Foobar);
            
            NSMutableArray * const members = [NSMutableArray array];
            for (i += 1; i < objcTypeLength; ) {
                if (objcType[i] == ')') {
                    break;
                }
                XZObjcTypeDescriptor *member = [XZObjcTypeDescriptor descriptorForObjcType:(objcType + i)];
                if (member == nil) {
                    return nil;
                }
                [members addObject:member];
                i += member.raw.length; // 移动到下一个字符
                // 共用体对齐是成员中最大的
                _size = MAX(_size, member.size);
                _sizeInBit = MAX(_sizeInBit, member.sizeInBit);
                _alignment = MAX(_alignment, member.alignment);
            }
            _members = members.copy;
            
            _raw = [[NSString alloc] initWithBytes:objcType length:(i + 1) encoding:NSASCIIStringEncoding];
            [self size:&_size alignment:&_alignment forObjcType:_raw];
            
            _type = XZObjcTypeUnion;
            break;
        }
        case '{': { // {name=type...}
            if (objcTypeLength < 4) {
                return nil;
            }
            
            size_t i = 1;
            do {
                if (i >= objcTypeLength) {
                    return nil;
                }
                if (objcType[i] == '=') {
                    break;
                }
                i += 1;
            } while (YES);
            _name = [[NSString alloc] initWithBytes:(objcType + 1) length:(i - 1) encoding:NSASCIIStringEncoding];
            
            NSMutableArray * const members = [NSMutableArray array];
            for (i += 1; i < objcTypeLength; ) {
                if (objcType[i] == '}') {
                    break;
                }
                XZObjcTypeDescriptor *member = [XZObjcTypeDescriptor descriptorForObjcType:(objcType + i)];
                if (member == nil) {
                    return nil;
                }
                [members addObject:member];
                i += member.raw.length;
            }
            _members = members.copy;
            
            _raw = [[NSString alloc] initWithBytes:objcType length:(i + 1) encoding:NSASCIIStringEncoding];
            if (![self size:&_size alignment:&_alignment forObjcType:_raw]) {
                if (members.count > 0) {
                    for (XZObjcTypeDescriptor *member in _members) {
                        if (member.type == XZObjcTypeBitField) {
                            
                        } else {
                            
                        }
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
                    _sizeInBit = _size * 8;
                    _alignment = _Alignof(struct Foobar);
                }
            }
            
            _type = XZObjcTypeStruct;
            break;
        }
        case '@': {
            // 对象类型的 type encoding 存在如下情形：
            // id                                                   => @
            // NSString *                                           => @"NSString"
            // id<UITableViewDelegate>                              => @"<UITableViewDelegate>"
            // UIView<UITableViewDataSource> *                      => @"UIView<UITableViewDataSource>"
            // id<UITableViewDataSource, UITableViewDelegate>       => @"<UITableViewDataSource><UITableViewDelegate>"
            // UIView<UITableViewDataSource, UITableViewDelegate> * => @"UIView<UITableViewDataSource><UITableViewDelegate>"
            // 所以，如果长度超 1 则表示可能包含类名。
            if (objcTypeLength > 1) {
                if (objcType[1] != '"') { // 第2个字符必须时双引号
                    objcTypeLength = 1;
                } else if (objcTypeLength < 4) { // 包含类名时，长度不能小于4，比如 @"A"
                    objcTypeLength = 1;
                } else {
                    size_t newLength = 1;
                    for (size_t i = 2; i < objcTypeLength; i++) {
                        if (objcType[i] == '"') {
                            newLength = i + 1;
                            break;
                        }
                    }
                    objcTypeLength = newLength;
                }
            }
            
            _raw  = [[NSString alloc] initWithBytes:objcType length:objcTypeLength encoding:NSASCIIStringEncoding];
            _type = XZObjcTypeObject;
            _name = @"object";
            _size = sizeof(id);
            _sizeInBit = _size * 8;
            _alignment = _Alignof(id);
            
            if (objcTypeLength > 1) {
                NSRange range = [_raw rangeOfString:@"<"];
                if (range.location == NSNotFound) {
                    NSString * const className = [_raw substringWithRange:NSMakeRange(2, objcTypeLength - 3)];
                    _subtype = NSClassFromString(className);
                    _name = [NSString stringWithFormat:@"%@ %@", className, _name];
                    _protocols = nil;
                } else {
                    if (range.location > 2) { // @"Name<Protocol>"
                        NSString * const className = [_raw substringWithRange:NSMakeRange(2, (range.location + 1) - 3)];
                        _subtype = NSClassFromString(className);
                        _name = [NSString stringWithFormat:@"%@ %@", className, _name];
                    }
                    // 起点：第一个 < 符号的下一个字符。长度：总长度 - 第一个 < 左边的字符长度 - 末尾的双引号 - 末尾的 > 符号
                    NSString * const protocolString = [_raw substringWithRange:NSMakeRange(range.location + 1, objcTypeLength - (range.location + 1) - 1 - 1)];
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
    return [self descriptorWithType:_type name:_name qualifiers:qualifiers size:_size sizeInBit:_sizeInBit raw:_raw alignment:_alignment members:_members subtype:_subtype protocols:_protocols];
}

+ (instancetype)descriptorWithType:(XZObjcType)type name:(NSString *)name qualifiers:(XZObjcQualifiers)qualifiers size:(size_t)size sizeInBit:(size_t)sizeInBit raw:(NSString *)encoding alignment:(size_t)alignment members:(NSArray<XZObjcTypeDescriptor *> *)members subtype:(Class)subtype protocols:(NSArray<Protocol *> *)protocols {
    return withStorage(^id(XZObjcTypeStorage const storage) {
        NSNumber * const key = @(qualifiers);
        XZObjcTypeDescriptor *descriptor = storage[encoding][key];
        if (descriptor) {
            return descriptor;
        }
        descriptor = [[self alloc] initWithRaw:type name:name qualifiers:qualifiers size:size sizeInBit:sizeInBit raw:encoding alignment:alignment members:members subtype:subtype protocols:protocols];
        NSMutableDictionary *dictM = storage[encoding];
        if (dictM == nil) {
            dictM = [NSMutableDictionary dictionary];
            storage[encoding] = dictM;
        }
        dictM[key] = descriptor;
        return descriptor;
    });
}

- (instancetype)initWithRaw:(XZObjcType)type name:(NSString *)name qualifiers:(XZObjcQualifiers)qualifiers size:(size_t)size sizeInBit:(size_t)sizeInBit raw:(NSString *)raw alignment:(size_t)alignment members:(NSArray<XZObjcTypeDescriptor *> *)members subtype:(Class)subtype protocols:(NSArray<Protocol *> *)protocols {
    self = [super init];
    if (self) {
        _raw = raw;
        _type = type;
        _name = name;
        _qualifiers = qualifiers;
        _size = size;
        _sizeInBit = sizeInBit;
        _alignment = alignment;
        _members = members.copy;
        _subtype = subtype;
        _protocols = protocols.copy;
    }
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
        [self.members enumerateObjectsUsingBlock:^(XZObjcTypeDescriptor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@>,\n", obj, ((id)obj.subtype ?: obj.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        members = stringM;
    }
    
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: %lu, raw: %@, sizeInBit: %lu, size: %lu, alignment: %lu, subtype: %@, protocols: %@, members: %@>", NSStringFromClass(self.class), self, self.name, (unsigned long)self.type, self.raw, self.sizeInBit, self.size, self.alignment, self.subtype, protocols, members];
}

#pragma mark - Provider

typedef struct XZObjcTypeLayout {
    size_t size;
    size_t alignment;
} XZObjcTypeLayout;

+ (NSMutableDictionary<NSString *, NSValue *> *)typeLayouts {
    static NSMutableDictionary<NSString *, NSValue *> *_typeLayouts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _typeLayouts = [NSMutableDictionary dictionary];
    });
    return _typeLayouts;
}

+ (void)setSize:(size_t)size alignment:(size_t)alignment forObjcType:(const char * const)objcType {
    if (objcType == NULL) {
        return;
    }
    NSString *       const typeName   = [NSString stringWithCString:objcType encoding:NSASCIIStringEncoding];
    XZObjcTypeLayout const typeLayout = {size, alignment};
    self.typeLayouts[typeName] = [NSValue valueWithBytes:&typeLayout objCType:@encode(XZObjcTypeLayout)];
}

+ (BOOL)size:(size_t *)size alignment:(size_t *)alignment forObjcType:(NSString * const)typeName {
    XZObjcTypeLayout typeLayout = {0, 0};
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


static id withStorage(id (^block)(XZObjcTypeStorage const storage)) {
    static dispatch_semaphore_t _lock;
    static XZObjcTypeStorage _storage = nil;
    
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
