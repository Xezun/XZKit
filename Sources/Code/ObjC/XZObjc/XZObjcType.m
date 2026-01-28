//
//  XZObjcType.m
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import "XZObjcType.h"
#import "XZMacros.h"

/// 对象类型的 XZObjcType 缓存。
static id _Nullable withLock(id (^NS_NOESCAPE block)(CFMutableDictionaryRef const storage));
/// 基本类型的 XZObjcType 缓存，在 +initialize 方法中只初始化。
static XZObjcType __unsafe_unretained *_basicTypes[CHAR_MAX] = { NULL };

/// 由元素组成的集合类型。
@interface XZObjcElementType : XZObjcType
- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding elementType:(XZObjcType *)elementType capacity:(NSInteger)capacity;
@end

@interface XZObjcUnionType : XZObjcType
- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding members:(NSArray<XZObjcType *> *)members;
@end

/// 由成员组成的复合类型。
@interface XZObjcStructType : XZObjcType
- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding members:(NSArray<XZObjcType *> *)members;
@end

/// 对象类型。
@interface XZObjcObjectType : XZObjcType
- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding classType:(Class)classType protocols:(NSArray<Protocol *> *)protocols;
@end

@interface XZObjcType () {
    XZStdcType _type;
    NSString *_name;
    NSString *_encoding;
}
@end

@implementation XZObjcType

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

+ (XZObjcType *)typeForType:(XZStdcType)type {
    switch (type) {
        case XZStdcTypeUnknown:
        case XZStdcTypeChar:
        case XZStdcTypeUnsignedChar:
        case XZStdcTypeInt:
        case XZStdcTypeUnsignedInt:
        case XZStdcTypeShort:
        case XZStdcTypeUnsignedShort:
        case XZStdcTypeLong:
        case XZStdcTypeUnsignedLong:
        case XZStdcTypeInt128:
        case XZStdcTypeUnsignedInt128:
        case XZStdcTypeLongLong:
        case XZStdcTypeUnsignedLongLong:
        case XZStdcTypeFloat:
        case XZStdcTypeDouble:
        case XZStdcTypeLongDouble:
        case XZStdcTypeBool:
        case XZStdcTypeVoid:
        case XZStdcTypeString:
        case XZStdcTypeSelector:
        case XZStdcTypePointer:
        case XZStdcTypeVector:
        case XZStdcTypeArray:
        case XZStdcTypeBitField:
        case XZStdcTypeUnion:
        case XZStdcTypeStruct:
        case XZStdcTypeClass:
        case XZStdcTypeObject:
            return _basicTypes[type];
    }
    NSString *reason = [NSString stringWithFormat:@"参数 type = %lu 的值不正确，必须是 XZStdcType 枚举值。", (unsigned long)type];
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
}

+ (XZObjcType *)typeForEncoding:(const char * const)encoding {
    if (encoding == NULL) {
        return nil;
    }
    
    NSInteger const encodingLength = strlen(encoding);
    if (encodingLength == 0) {
        return nil;
    }
    
    // 过滤处理修饰符。
    NSInteger i = 0;
    while (i < encodingLength) {
        switch (encoding[i]) {
            case _C_CONST:
            case _C_IN:
            case _C_INOUT:
            case _C_OUT:
            case _C_BYCOPY:
            case _C_BYREF:
            case _C_ONEWAY:
            case _C_COMPLEX:
            case _C_ATOMIC:
            case _C_GNUREGISTER:
                i += 1;
                continue;
            default: {
                // 非修饰字符，结束遍历
                break;
            }
        }
        break;
    }
    
    // 只有修饰符，不是合法的编码
    NSInteger const newLength = encodingLength - i;
    if (newLength < 1) {
        return nil;
    }
    
    // 重新定位字符编码的起点
    return [self typeForEncoding:(encoding + i) length:newLength];
}

+ (XZObjcType *)typeForEncoding:(const char * const)encoding length:(NSInteger const)length {
    // 首个字符即为 C 类型
    XZStdcType const stdcType = (XZStdcType)encoding[0];
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
            return _basicTypes[stdcType];
        }
        case XZStdcTypePointer: {
            XZObjcType * const _element = [XZObjcType typeForEncoding:(encoding + 1)];
            if (_element == nil) {
                return nil;
            }
            NSString * const _name     = [NSString stringWithFormat:@"%@ *", _element.name];
            NSString * const _encoding = [[NSString alloc] initWithBytes:encoding length:(1 + _element.encoding.length) encoding:NSUTF8StringEncoding];
            return [[XZObjcElementType alloc] initWithType:stdcType name:_name encoding:_encoding elementType:_element capacity:1];
        }
        case XZStdcTypeBitField: {
            // 位域，结构体成员。
            // struct Foobar { int a:1; int b: 22 } => {Foobar=b1b22}
            // 从位域的编码中，只能获取占用内存的位数，而实际占用内存和对齐，跟声明位域的类型有关。
            // 比如 int a:1 占用 1 位 4 字节，long a:1 占用 1 位 8 字节。
            if (length < 2) {
                return nil;
            }
            
            NSInteger numberOfBits = 0;
            NSInteger index = 1;
            while (index < length) {
                const char number = encoding[index];
                // 遇到非数字，编码结束
                if (number < '0' || number > '9') {
                    break;
                }
                // 位域编码中，是以十进制表示位域宽度的。
                numberOfBits = numberOfBits * 10 + (number - '0');
                index += 1;
            }
            // 不合法的编码
            if (numberOfBits == 0) {
                return nil;
            }
            
            NSString * const _encoding = [[NSString alloc] initWithBytes:encoding length:index encoding:NSUTF8StringEncoding];
            NSString * const _name     = [NSString stringWithFormat:@"bitfield_%ld", (long)numberOfBits];
            return [[XZObjcElementType alloc] initWithType:stdcType name:_name encoding:_encoding elementType:_basicTypes[stdcType] capacity:numberOfBits];
        }
        case XZStdcTypeArray: {
            // int[10]    => [10i]
            // int[10][2] => [10[2i]]
            if (length < 4) {
                return nil;
            }
            
            NSInteger index = 1;
            
            // 元素数量
            NSInteger count = 0;
            while (index < length) {
                char const number = encoding[index];
                if (number < '0' || number > '9') {
                    break;
                }
                count = count * 10 + (number - '0');
                index += 1;
            }
            if (count == 0) {
                return nil;
            }
            
            // 元素类型
            XZObjcType *_element = [XZObjcType typeForEncoding:(encoding + index)];
            if (_element == nil) {
                return nil;
            }
            
            // 查找结尾字符
            index += _element.encoding.length; // 定位到 member 的下一个字符
            if (index >= length) {
                return nil;
            }
            if (encoding[index] != ']') {
                return nil;
            }
            
            NSString * const _encoding = [[NSString alloc] initWithBytes:encoding length:(index + 1) encoding:NSUTF8StringEncoding];
            NSString * const _name     = [NSString stringWithFormat:@"%@[%ld]", _element.name, (long)count];
            return [[XZObjcElementType alloc] initWithType:stdcType name:_name encoding:_encoding elementType:_element capacity:count];
        }
        case XZStdcTypeUnion: {
            // (Foobar=icq)
            if (length < 4) {
                return nil;
            }
            
            NSInteger i = 1;
            
            // 定位到 = 字符，获取共用体名字
            do {
                if (i >= length) {
                    return nil;
                }
                if (encoding[i] == '=') {
                    break;
                }
                i += 1;
            } while (YES);
            NSString * const _name = [[NSString alloc] initWithBytes:(encoding + 1) length:(i - 1) encoding:NSUTF8StringEncoding];
            
            NSMutableArray * const _members = [NSMutableArray array];
            while (YES) {
                i += 1;
                // 未匹配到结尾，编码不合法
                if (i >= length) {
                    return nil;
                }
                // 匹配结尾
                if (encoding[i] == ')') {
                    break;
                }
                // 匹配成员
                XZObjcType *member = [XZObjcType typeForEncoding:(encoding + i)];
                if (member == nil) {
                    return nil;
                }
                [_members addObject:member];
                
                // 移动到下一个字符
                i += (member.encoding.length - 1);
            }
            
            NSString * const _encoding = [[NSString alloc] initWithBytes:encoding length:(i + 1) encoding:NSUTF8StringEncoding];
            return [[XZObjcUnionType alloc] initWithType:stdcType name:_name encoding:_encoding members:_members];
        }
        case XZStdcTypeStruct: {
            // 结构体编码格式：{name=type...}
            
            // 结构体编码至少需要4个字符
            if (length < 4) {
                return nil;
            }
            
            // 从第二个字符开始遍历，找到等号 = 字符，确定结构体名称。
            // 遍历结束时，i 指向等号字符的位置。
            NSInteger i = 1;
            do {
                if (i >= length) {
                    return nil;
                }
                if (encoding[i] == '=') {
                    break;
                }
                i += 1;
            } while (YES);
            NSString * const _name = [[NSString alloc] initWithBytes:(encoding + 1) length:(i - 1) encoding:NSUTF8StringEncoding];
            
            // 解析结构体成员
            NSMutableArray * const _members = [NSMutableArray array];
            while ( YES ) {
                i += 1;
                // 未匹配到结尾，编码不合法
                if (i >= length) {
                    return nil;
                }
                // 匹配到末尾
                if (encoding[i] == '}') {
                    break;
                }
                // 匹配成员
                XZObjcType *member = [XZObjcType typeForEncoding:(encoding + i)];
                if (member == nil) {
                    return nil;
                }
                [_members addObject:member];
                // 将 i 定位到 member 的最后一个字符上
                i += (member.encoding.length - 1);
            }
            
            NSString * const _encoding = [[NSString alloc] initWithBytes:encoding length:(i + 1) encoding:NSUTF8StringEncoding];
            return [[XZObjcStructType alloc] initWithType:stdcType name:_name encoding:_encoding members:_members];
        }
        case XZStdcTypeObject: {
            // 对象类型的 type encoding 存在如下情形：
            // id                                                   => @
            // NSString *                                           => @"NSString"
            // id<UITableViewDelegate>                              => @"<UITableViewDelegate>"
            // UIView<UITableViewDataSource> *                      => @"UIView<UITableViewDataSource>"
            // id<UITableViewDataSource, UITableViewDelegate>       => @"<UITableViewDataSource><UITableViewDelegate>"
            // UIView<UITableViewDataSource, UITableViewDelegate> * => @"UIView<UITableViewDataSource><UITableViewDelegate>"
            
            // 编码长度只有 1 说明是 id 类型
            if (length == 1) {
                return _basicTypes[XZStdcTypeObject];
            }
            
            // 第二个字符不是引号，说明是 id 类型
            if (encoding[1] != '"') {
                return _basicTypes[XZStdcTypeObject];
            }
            
            // 非 id 类型对象，编码长度不能小于4，比如 @"A"
            if (length < 4) {
                return nil;
            }
            
            // 查缓存：确定类型编码，根据类型编码查缓存。
            NSString *_encoding  = nil;
            for (NSInteger i = 2; i < length; i++) {
                // 类型编码的终止符号：第二个双引号
                if (encoding[i] == '"') {
                    NSInteger const newLength = (i + 1);
                    _encoding = [[NSString alloc] initWithBytes:encoding length:newLength encoding:NSUTF8StringEncoding];
                    XZObjcType *cachedType = withLock(^id(const CFMutableDictionaryRef storage) {
                        CFTypeRef value = CFDictionaryGetValue(storage, (__bridge CFStringRef)_encoding);
                        return (__bridge id)value;
                    });
                    if (cachedType) {
                        return cachedType;
                    }
                    break;
                }
            }
            
            // 类型编码不合法
            if (_encoding == nil) {
                return nil;
            }
            
            // 遍历字符串，分别解析出对象类名、遵循的协议名。
            
            /// 遍历时对字符的匹配模式，判断字符是类名，还是协议名。
            typedef enum : NSUInteger {
                MatchModeNone,
                /// 匹配名称模式
                MatchModeName,
                /// 匹配协议模式
                MatchModeProtocol
            } MatchMode;
            
            MatchMode mode = MatchModeName;
            NSRange nameRange = NSMakeRange(2, 0);
            NSRange protocolRange = NSMakeRange(NSNotFound, 0);
            // 遍历时存储的为协议名（字符串），遍历后处理为协议对象。
            NSMutableArray *_protocols = [NSMutableArray array];
            for (NSInteger i = 2; i < length; i++) {
                switch (encoding[i]) {
                    case '<':
                        mode = MatchModeProtocol;
                        protocolRange.location = i + 1;
                        protocolRange.length = 0;
                        continue;
                    case '>':
                        mode = MatchModeNone;
                        if (protocolRange.length > 0) {
                            NSString *protocolName = [[NSString alloc] initWithBytes:(encoding + protocolRange.location) length:protocolRange.length encoding:NSUTF8StringEncoding];
                            [_protocols addObject:protocolName];
                        }
                        protocolRange.location = NSNotFound;
                        protocolRange.length = 0;
                        continue;
                    case '"':
                        if (mode == MatchModeProtocol) {
                            return nil;
                        }
                        break;
                    default:
                        switch (mode) {
                            case MatchModeName:
                                nameRange.length += 1;
                                break;
                            case MatchModeProtocol:
                                protocolRange.length += 1;
                                break;
                            default:
                                return nil;
                        }
                        continue;
                }
                break;
            }
            
            Class _classType = Nil;
            NSMutableString *_name = nil;
            if (nameRange.length > 0) {
                _name = [[NSMutableString alloc] initWithBytes:(encoding + nameRange.location) length:nameRange.length encoding:NSUTF8StringEncoding];
                _classType = NSClassFromString(_name);
            } else {
                _name = [[NSMutableString alloc] initWithString:@"id"];
                _classType = Nil;
            }
            
            if (_protocols.count > 0) {
                for (NSInteger i = 0; i < _protocols.count; i++) {
                    NSString * const protocolName = _protocols[i];
                    Protocol *protocol = NSProtocolFromString(protocolName);
                    if (protocol == nil) {
                        return nil;
                    }
                    [_name appendFormat:@"<%@>", protocolName];
                    _protocols[i] = protocol;
                }
            }
            
            if (nameRange.length > 0) {
                [_name appendString:@" *"];
            }
            
            return withLock(^id(const CFMutableDictionaryRef storage) {
                CFTypeRef value = CFDictionaryGetValue(storage, (__bridge CFStringRef)_encoding);
                if (value) {
                    return (__bridge id)value;
                }
                XZObjcType *type = [[XZObjcObjectType alloc] initWithType:stdcType name:_name encoding:_encoding classType:_classType protocols:_protocols];
                CFDictionarySetValue(storage, (__bridge CFStringRef)_encoding, (__bridge CFTypeRef)type);
                return type;
            });
        }
        default: {
            return nil;
            break;
        }
    }
}

- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding {
    self = [super init];
    if (self) {
        _type = type;
        _name = name.copy;
        _encoding = encoding.copy;
    }
    return self;
}

- (XZObjcType *)elementType {
    return nil;
}

- (NSInteger)capacity {
    return 0;
}

- (XZStdcStructType)structType {
    return XZStdcStructTypeUnknown;
}

- (NSArray<XZObjcType *> *)members {
    return @[];
}

- (Class)classType {
    return Nil;
}

- (NSArray<Protocol *> *)protocols {
    return @[];
}

- (NSString *)descriptionWithIndent:(NSInteger)indent {
    NSString *padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
    
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendFormat:@"%@<%@: %p, { \n", padding, [XZObjcType class], self];
    [description appendFormat:@"%@    type: %@, \n", padding, NSStringFromXZStdcType(self.type)];
    [description appendFormat:@"%@    name: %@, \n", padding, self.name];
    [description appendFormat:@"%@    encoding: %@, \n", padding, self.encoding];
    
    switch (self.type) {
        case XZStdcTypePointer:
        case XZStdcTypeArray:
        case XZStdcTypeBitField:
            [description appendFormat:@"%@    elementType: %@, \n", padding, [self.elementType descriptionWithIndent:(indent + 1)]];
            [description appendFormat:@"%@    capacity: %ld \n", padding, self.capacity];
            break;
            
        case XZStdcTypeUnion:
        case XZStdcTypeStruct:
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
            break;
        case XZStdcTypeObject:
            [description appendFormat:@"%@    classType: %@, \n", padding, self.classType];
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
            break;
        default:
            [description deleteCharactersInRange:NSMakeRange(description.length - 3, 1)];
            break;
    }
    
    [description appendFormat:@"%@}>", padding];
    return description;
}

- (NSString *)description {
    return [self descriptionWithIndent:0];
}

+ (void)initialize {
    if (self == [XZObjcType class]) {
        
#define XZObjcRetain(object) (__bridge id)(__bridge_retained CFTypeRef)object
#define XZObjcTypeMake(type) { \
    const char * const typeEncoding = @encode(type);\
    XZStdcType   const stdcType     = (XZStdcType)typeEncoding[0]; \
    NSString   * const encoding     = [NSString stringWithFormat:@"%s", typeEncoding]; \
    NSString   * const name         = @"" # type; \
    _basicTypes[stdcType] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]); \
}
        {
            typedef void (unknown)(void);
            XZObjcTypeMake(unknown);
        }
        XZObjcTypeMake(char);
        XZObjcTypeMake(unsigned char);
        XZObjcTypeMake(int);
        XZObjcTypeMake(unsigned int);
        XZObjcTypeMake(short);
        XZObjcTypeMake(unsigned short);
        XZObjcTypeMake(long);
        XZObjcTypeMake(unsigned long);
        { // int_128
            XZStdcType const stdcType = (XZStdcType)_C_INT128;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_INT128];
            NSString * const name = @"int128";
            _basicTypes[_C_INT128] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
        { // unsigned int_128
            XZStdcType const stdcType = (XZStdcType)_C_UINT128;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_UINT128];
            NSString * const name = @"unsigned int128";
            _basicTypes[_C_UINT128] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
#if XZ_TYPE_LLONG_IS_LONG
        { // long long
            XZStdcType const stdcType = (XZStdcType)_C_LNG_LNG;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_LNG_LNG];
            NSString * const name = @"long long";
            _basicTypes[_C_LNG_LNG] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
        { // unsigned long long
            XZStdcType const stdcType = (XZStdcType)_C_ULNG_LNG;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_ULNG_LNG];
            NSString * const name = @"unsigned long long";
            _basicTypes[_C_ULNG_LNG] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
#else
        XZObjcTypeMake(long long);
        XZObjcTypeMake(unsigned long long);
#endif
        XZObjcTypeMake(float);
        XZObjcTypeMake(double);
#if TYPE_LONGDOUBLE_IS_DOUBLE
        { // long double
            XZStdcType const stdcType = (XZStdcType)_C_LNG_DBL;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_LNG_DBL];
            NSString * const name = @"long double";
            _basicTypes[_C_LNG_DBL] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
#else
        XZObjcTypeMake(long double);
#endif
        XZObjcTypeMake(bool);
        XZObjcTypeMake(void);
        { // c string
            typedef char *string;
            XZObjcTypeMake(string);
        }
        XZObjcTypeMake(SEL);
        { // pointer
            XZStdcType const stdcType = (XZStdcType)_C_PTR;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_PTR];
            NSString * const name = @"pointer";
            _basicTypes[_C_PTR] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
        { // c array
            XZStdcType const stdcType = (XZStdcType)_C_ARY_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_ARY_B, _C_ARY_E];
            NSString * const name = @"array";
            _basicTypes[_C_ARY_B] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
        { // c++ vector
            XZStdcType const stdcType = (XZStdcType)_C_VECTOR;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_VECTOR];
            NSString * const name = @"vector";
            _basicTypes[_C_VECTOR] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
        { // bit field
            XZStdcType const stdcType = (XZStdcType)_C_BFLD;
            NSString * const encoding = [NSString stringWithFormat:@"%c", _C_BFLD];
            NSString * const name = @"bitfield";
            _basicTypes[_C_BFLD] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
        { // union
            XZStdcType const stdcType = (XZStdcType)_C_UNION_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_UNION_B, _C_UNION_E];
            NSString * const name = @"union";
            _basicTypes[_C_UNION_B] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
        { // union
            XZStdcType const stdcType = (XZStdcType)_C_STRUCT_B;
            NSString * const encoding = [NSString stringWithFormat:@"%c%c", _C_STRUCT_B, _C_STRUCT_E];
            NSString * const name = @"struct";
            _basicTypes[_C_STRUCT_B] = XZObjcRetain([[XZObjcType alloc] initWithType:stdcType name:name encoding:encoding]);
        }
        XZObjcTypeMake(Class);
        XZObjcTypeMake(id);
#undef XZObjcTypeMake
#undef XZObjcRetain
    }
}

@end

static id _Nullable withLock(id (^NS_NOESCAPE block)(CFMutableDictionaryRef const storage)) {
    static dispatch_semaphore_t _lock;
    static CFMutableDictionaryRef _storage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = dispatch_semaphore_create(1);
        _storage = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id const value = block(_storage);
    dispatch_semaphore_signal(_lock);
    
    return value;
}

@implementation XZObjcElementType {
    XZObjcType *_elementType;
    NSInteger _capacity;
}

- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding elementType:(XZObjcType *)elementType capacity:(NSInteger)capacity {
    self = [super initWithType:type name:name encoding:encoding];
    if (self) {
        _elementType = elementType;
        _capacity = capacity;
    }
    return self;
}

- (XZObjcType *)elementType {
    return _elementType;
}

- (NSInteger)capacity {
    return _capacity;
}

@end

@implementation XZObjcUnionType {
    NSArray<XZObjcType *> *_members;
}

- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding members:(NSArray<XZObjcType *> *)members {
    self = [super initWithType:type name:name encoding:encoding];
    if (self) {
        
        _members = members.copy;
    }
    return self;
}

- (NSArray<XZObjcType *> *)members {
    return _members;
}

@end

@implementation XZObjcStructType {
    XZStdcStructType _structType;
    NSArray<XZObjcType *> *_members;
}

- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding members:(NSArray<XZObjcType *> *)members {
    self = [super initWithType:type name:name encoding:encoding];
    if (self) {
        _structType = XZStdcStructTypeFromString(name);
        _members = members.copy;
    }
    return self;
}

- (XZStdcStructType)structType {
    return _structType;
}

- (NSArray<XZObjcType *> *)members {
    return _members;
}

@end

@implementation XZObjcObjectType {
    Class _classType;
    NSArray<Protocol *> *_protocols;
}

- (instancetype)initWithType:(XZStdcType)type name:(NSString *)name encoding:(NSString *)encoding classType:(Class)classType protocols:(NSArray<Protocol *> *)protocols {
    self = [super initWithType:type name:name encoding:encoding];
    if (self) {
        _classType = classType;
        _protocols = protocols.copy;
    }
    return self;
}

- (Class)classType {
    return _classType;
}

- (NSArray<Protocol *> *)protocols {
    return _protocols;
}

@end

NSString *NSStringFromXZStdcType(XZStdcType type) {
#define CaseStdcType(aType) case aType: return @"" # aType
    switch (type) {
        CaseStdcType(XZStdcTypeUnknown);
        CaseStdcType(XZStdcTypeChar);
        CaseStdcType(XZStdcTypeUnsignedChar);
        CaseStdcType(XZStdcTypeInt);
        CaseStdcType(XZStdcTypeUnsignedInt);
        CaseStdcType(XZStdcTypeShort);
        CaseStdcType(XZStdcTypeUnsignedShort);
        CaseStdcType(XZStdcTypeLong);
        CaseStdcType(XZStdcTypeUnsignedLong);
        CaseStdcType(XZStdcTypeInt128);
        CaseStdcType(XZStdcTypeUnsignedInt128);
        CaseStdcType(XZStdcTypeLongLong);
        CaseStdcType(XZStdcTypeUnsignedLongLong);
        CaseStdcType(XZStdcTypeFloat);
        CaseStdcType(XZStdcTypeDouble);
        CaseStdcType(XZStdcTypeLongDouble);
        CaseStdcType(XZStdcTypeBool);
        CaseStdcType(XZStdcTypeVoid);
        CaseStdcType(XZStdcTypeString);
        CaseStdcType(XZStdcTypeSelector);
        CaseStdcType(XZStdcTypePointer);
        CaseStdcType(XZStdcTypeVector);
        CaseStdcType(XZStdcTypeArray);
        CaseStdcType(XZStdcTypeBitField);
        CaseStdcType(XZStdcTypeUnion);
        CaseStdcType(XZStdcTypeStruct);
        CaseStdcType(XZStdcTypeClass);
        CaseStdcType(XZStdcTypeObject);
    }
#undef CaseStdcType
}


XZStdcStructType XZStdcStructTypeFromString(NSString *name) {
    if ([name isEqualToString:@"CGRect"]) {
        return XZStdcStructTypeCGRect;
    }
    if ([name isEqualToString:@"CGSize"]) {
        return XZStdcStructTypeCGSize;
    }
    if ([name isEqualToString:@"CGPoint"]) {
        return XZStdcStructTypeCGPoint;
    }
    if ([name isEqualToString:@"CGVector"]) {
        return XZStdcStructTypeCGVector;
    }
    if ([name isEqualToString:@"CGAffineTransform"]) {
        return XZStdcStructTypeCGAffineTransform;
    }
    if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
        return XZStdcStructTypeNSDirectionalEdgeInsets;
    }
    if ([name isEqualToString:@"NSRange"]) {
        return XZStdcStructTypeNSRange;
    }
    if ([name isEqualToString:@"UIEdgeInsets"]) {
        return XZStdcStructTypeUIEdgeInsets;
    }
    if ([name isEqualToString:@"UIOffset"]) {
        return XZStdcStructTypeUIOffset;
    }
    return XZStdcStructTypeUnknown;
}

NSString *NSStringFromXZStdcModifiers(XZStdcModifiers modifiers) {
    NSMutableArray *components = [NSMutableArray array];
    if (modifiers & XZStdcModifierConst) {
        [components addObject:@"const"];
    }
    if (modifiers & XZStdcModifierIn) {
        [components addObject:@"in"];
    }
    if (modifiers & XZStdcModifierInout) {
        [components addObject:@"inout"];
    }
    if (modifiers & XZStdcModifierOut) {
        [components addObject:@"out"];
    }
    if (modifiers & XZStdcModifierByCopy) {
        [components addObject:@"bycopy"];
    }
    if (modifiers & XZStdcModifierByRef) {
        [components addObject:@"byref"];
    }
    if (modifiers & XZStdcModifierOneway) {
        [components addObject:@"oneway"];
    }
    if (modifiers & XZStdcModifierComplex) {
        [components addObject:@"complex"];
    }
    if (modifiers & XZStdcModifierAtomic) {
        [components addObject:@"atomic"];
    }
    if (modifiers & XZStdcModifierGNURegister) {
        [components addObject:@"register"];
    }
    if (modifiers & XZStdcModifierReadonly) {
        [components addObject:@"readonly"];
    }
    if (modifiers & XZStdcModifierCopy) {
        [components addObject:@"copy"];
    }
    if (modifiers & XZStdcModifierRetain) {
        [components addObject:@"retain"];
    }
    if (modifiers & XZStdcModifierWeak) {
        [components addObject:@"weak"];
    }
    if (modifiers & XZStdcModifierNonatomic) {
        [components addObject:@"nonatomic"];
    }
    if (modifiers & XZStdcModifierGetter) {
        [components addObject:@"getter"];
    }
    if (modifiers & XZStdcModifierSetter) {
        [components addObject:@"setter"];
    }
    if (modifiers & XZStdcModifierDynamic) {
        [components addObject:@"dynamic"];
    }
    return [NSString stringWithFormat:@"[%@]", [components componentsJoinedByString:@", "]];
}
