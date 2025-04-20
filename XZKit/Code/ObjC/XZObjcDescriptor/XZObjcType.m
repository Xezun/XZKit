//
//  XZObjcType.m
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import "XZObjcType.h"
#import "XZMacro.h"

static id withStorage(id (^block)(NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, XZObjcType *> *> * const storage)) {
    static dispatch_semaphore_t _lock;
    static NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, XZObjcType *> *> *_storage = nil;
    
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

struct XZObjcTypeEmptyStruct { };

union XZObjcTypeEmptyUnion { };

typedef struct XZObjcRawAlignment {
    size_t size;
    size_t alignment;
} XZObjcRawAlignment;

@interface XZObjcType ()
+ (XZObjcRawAlignment)alignmentForeEncoding:(const char *)encoding;
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
    }
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

+ (XZObjcType *)typeWithEncoding:(const char *)typeEncoding {
    return [self typeWithEncoding:typeEncoding qualifiers:kNilOptions];
}

+ (XZObjcType *)typeWithEncoding:(const char *)typeEncoding qualifiers:(XZObjcQualifiers)qualifiers {
    if (typeEncoding == NULL) {
        return nil;
    }
    
    size_t typeEncodingLength = strlen(typeEncoding);
    if (typeEncodingLength == 0) {
        return nil;
    }
    
    { // 变量修饰符：方法参数的类型编码可能会包含类型修饰符
        unsigned long i = 0;
        while (i < typeEncodingLength) {
            switch (typeEncoding[i]) {
                case 'r': {
                    qualifiers |= XZObjcQualifierConst;
                    i += 1;
                    continue;
                }
                case 'n': {
                    qualifiers |= XZObjcQualifierIn;
                    i += 1;
                    continue;
                }
                case 'N': {
                    qualifiers |= XZObjcQualifierInout;
                    i += 1;
                    continue;
                }
                case 'o': {
                    qualifiers |= XZObjcQualifierOut;
                    i += 1;
                    continue;
                }
                case 'O': {
                    qualifiers |= XZObjcQualifierByCopy;
                    i += 1;
                    continue;
                }
                case 'R': {
                    qualifiers |= XZObjcQualifierByRef;
                    i += 1;
                    continue;
                }
                case 'V': {
                    qualifiers |= XZObjcQualifierOneway;
                    i += 1;
                    continue;
                }
                default: {
                    break;
                }
            }
            break;
        }
        // 只有修饰符，不是合法的编码
        if (i >= typeEncodingLength) {
            return nil;
        }
        // 重新定位字符编码的起点
        typeEncoding = typeEncoding + i;
        typeEncodingLength -= i;
    }
    
    {
        NSString *encoding = [NSString stringWithCString:typeEncoding encoding:NSASCIIStringEncoding];
        
        XZObjcType *type = withStorage(^id(NSMutableDictionary<NSString *,NSMutableDictionary<NSNumber *,XZObjcType *> *> * const storage) {
            return storage[encoding][@(qualifiers)];;
        });
        
        if (type) {
            return type;
        }
    }
    
    XZObjcRaw  _raw       = XZObjcRawUnknown;
    NSString * _name      = nil;
    size_t     _size      = 0;
    size_t     _sizeInBit = 0;
    NSString * _encoding  = nil;
    size_t     _alignment = 0;
    NSArray  * _members   = nil;
    Class      _subtype   = Nil;
    NSArray  * _protocols = nil;
    
    switch (typeEncoding[0]) {
        case 'c': {
            _raw = XZObjcRawChar;
            _name = @"char";
            _size = sizeof(char);
            _sizeInBit = _size * 8;
            _encoding  = @"c";
            _alignment = _Alignof(char);
            break;
        }
        case 'i': {
            _raw = XZObjcRawInt;
            _name = @"int";
            _size = sizeof(int);
            _sizeInBit = _size * 8;
            _encoding  = @"i";
            _alignment = _Alignof(int);
            break;
        }
        case 's': {
            _raw = XZObjcRawShort;
            _name = @"short";
            _size = sizeof(short);
            _sizeInBit = _size * 8;
            _encoding  = @"s";
            _alignment = _Alignof(short);
            break;
        }
        case 'l': {
            _raw = XZObjcRawLong;
            _name = @"long";
            _size = sizeof(long);
            _sizeInBit = _size * 8;
            _encoding  = @"l";
            _alignment = _Alignof(long);
            break;
        }
        case 'q': {
            _raw = XZObjcRawLongLong;
            _name = @"long long";
            _size = sizeof(long long);
            _sizeInBit = _size * 8;
            _encoding  = @"q";
            _alignment = _Alignof(long long);
            break;
        }
        case 'C': {
            _raw = XZObjcRawUnsignedChar;
            _name = @"unsigned char";
            _size = sizeof(unsigned char);
            _sizeInBit = _size * 8;
            _encoding  = @"C";
            _alignment = _Alignof(unsigned char);
            break;
        }
        case 'I': {
            _raw = XZObjcRawUnsignedInt;
            _name = @"unsigned int";
            _size = sizeof(unsigned int);
            _sizeInBit = _size * 8;
            _encoding  = @"I";
            _alignment = _Alignof(unsigned int);
            break;
        }
        case 'S': {
            _raw = XZObjcRawUnsignedShort;
            _name = @"unsigned short";
            _size = sizeof(unsigned short);
            _sizeInBit = _size * 8;
            _encoding  = @"S";
            _alignment = _Alignof(unsigned short);
            break;
        }
        case 'L': {
            _raw = XZObjcRawUnsignedLong;
            _name = @"unsigned long";
            _size = sizeof(unsigned long);
            _sizeInBit = _size * 8;
            _encoding  = @"L";
            _alignment = _Alignof(unsigned long);
            break;
        }
        case 'Q': {
            _raw = XZObjcRawUnsignedLongLong;
            _name = @"unsigned long long";
            _size = sizeof(unsigned long long);
            _sizeInBit = _size * 8;
            _encoding  = @"Q";
            _alignment = _Alignof(unsigned long long);
            break;
        }
        case 'f': {
            _raw = XZObjcRawFloat;
            _name = @"float";
            _size = sizeof(float);
            _sizeInBit = _size * 8;
            _encoding  = @"f";
            _alignment = _Alignof(float);
            break;
        }
        case 'd': {
            _raw = XZObjcRawDouble;
            _name = @"double";
            _size = sizeof(double);
            _sizeInBit = _size * 8;
            _encoding  = @"d";
            _alignment = _Alignof(double);
            break;
        }
        case 'D': {
            _raw = XZObjcRawLongDouble;
            _name = @"long double";
            _size = sizeof(long double);
            _sizeInBit = _size * 8;
            _encoding  = @"D";
            _alignment = _Alignof(long double);
            break;
        }
        case 'B': {
            _raw = XZObjcRawBool;
            _name = @"bool";
            _size = sizeof(bool);
            _sizeInBit = _size * 8;
            _encoding  = @"B";
            _alignment = _Alignof(bool);
            break;
        }
        case 'v': {
            _raw = XZObjcRawVoid;
            _name = @"void";
            _size = sizeof(void);
            _sizeInBit = _size * 8;
            _encoding  = @"v";
            _alignment = _Alignof(void);
            break;
        }
        case '*': {
            _raw = XZObjcRawString;
            _name = @"char *";
            _size = sizeof(char *);
            _sizeInBit = _size * 8;
            _encoding  = @"*";
            _alignment = _Alignof(char *);
            break;
        }
        case '@': {
            // id => @
            // NSString * => @"NSString"
            // id<UITableViewDelegate> => @"<UITableViewDelegate>"
            // id<UITableViewDataSource, UITableViewDelegate> => @"<UITableViewDataSource><UITableViewDelegate>"
            // UIView<UITableViewDataSource> * => @"UIView<UITableViewDataSource>"
            // UIView<UITableViewDataSource, UITableViewDelegate> * => @"UIView<UITableViewDataSource><UITableViewDelegate>"
            _raw = XZObjcRawObject;
            _name = @"object";
            _size = sizeof(id);
            _sizeInBit = _size * 8;
            if (typeEncodingLength == 1 || typeEncoding[1] != '"') {
                _encoding = @"@";
            } else if (typeEncodingLength <= 3) {
                return nil;
            } else {
                size_t i = 2;
                while (typeEncoding[i] != '"') {
                    i += 1;
                    if (i >= typeEncodingLength) {
                        return nil; // 没找到结束标记，错误的编码
                    }
                }
                const size_t newLength = i + 1;
                _encoding = [[NSString alloc] initWithBytes:typeEncoding length:newLength encoding:NSASCIIStringEncoding];
                if (newLength != typeEncodingLength) {
                    typeEncoding = [_encoding cStringUsingEncoding:NSASCIIStringEncoding];
                }
                
                NSCharacterSet * const set = [NSCharacterSet characterSetWithCharactersInString:@"@\">"];
                NSString       * string = [_encoding stringByTrimmingCharactersInSet:set];
                
                NSRange range = [string rangeOfString:@"<"];
                if (range.location == NSNotFound) {
                    _subtype = NSClassFromString(string);
                } else {
                    if (range.location > 0) {
                        _subtype = NSClassFromString([string substringToIndex:range.location]);
                    }
                    string = [string substringFromIndex:(range.location + 1)];
                    NSArray<NSString *> * const names = [string componentsSeparatedByString:@"><"];
                    NSMutableArray      * const protocols = [NSMutableArray arrayWithCapacity:names.count];
                    for (NSString * const name in names) {
                        Protocol *protocol = NSProtocolFromString(name);
                        if (protocol) {
                            [protocols addObject:protocol];
                        }
                    }
                    _protocols = protocols.copy;
                }
            }
            _alignment = _Alignof(id);
            break;
        }
        case '#': {
            _raw = XZObjcRawClass;
            _name = @"Class";
            _size = sizeof(Class);
            _sizeInBit = _size * 8;
            _encoding  = @"#";
            _alignment = _Alignof(Class);
            break;
        }
        case ':': {
            _raw = XZObjcRawSEL;
            _name = @"SEL";
            _size = sizeof(SEL);
            _sizeInBit = _size * 8;
            _encoding = @":";
            _alignment = _Alignof(SEL);
            break;
        }
        case '[': {
            // int[10] => [10i]
            // int[10][2] => [10[2i]]
            if (typeEncodingLength < 4) {
                return nil;
            }
            _raw = XZObjcRawArray;
            
            // 找到结尾位置
            size_t i = 0;
            size_t e = 0;
            while (true) {
                switch (typeEncoding[i]) {
                    case '[':
                        e += 1;
                        break;
                    case ']':
                        e -= 1;
                        break;
                    default:
                        break;
                }
                
                if (e == 0) {
                    break;
                }
                
                i += 1;
                
                if (i >= typeEncodingLength) {
                    return nil;
                }
            }
            if (e > 0) {
                return nil;
            }
            size_t const newLength = i + 1;
            if (newLength < 4) {
                return nil;
            }
            _encoding = [[NSString alloc] initWithBytes:typeEncoding length:newLength encoding:NSASCIIStringEncoding];
            if (newLength != typeEncodingLength) {
                typeEncoding = [_encoding cStringUsingEncoding:NSASCIIStringEncoding];
            }
            
            // 数组元素数量
            size_t count = 0;
            i = 1;
            while (YES) {
                const char number = typeEncoding[i];
                if (number < '0' || number > '9') {
                    break;
                }
                count = count * 10 + (typeEncoding[i] - '0');
                i += 1;
                if (i >= newLength) {
                    return nil; // typeEncoding 不合法
                }
            }
            if (count == 0) {
                return nil;
            }
            
            // 成员类型
            XZObjcType *member = [XZObjcType typeWithEncoding:typeEncoding + i];
            if (member == nil) {
                return nil;
            }
            
            _name = [NSString stringWithFormat:@"%@[%ld]", member.name, (long)count];
            _size = member.size * count;
            _sizeInBit = _size * 8;
            _alignment = member.alignment;
            _members = @[member];
            break;
        }
        case '{': { // {name=type...}
            _raw = XZObjcRawStruct;
            if (typeEncodingLength < 5) {
                return nil;
            }
            
            // 找到结束位置
            size_t i = 1;
            size_t e = 1;
            while (true) {
                switch (typeEncoding[i]) {
                    case '{':
                        e += 1;
                        break;
                    case '}':
                        e -= 1;
                        break;
                    default:
                        break;
                }
                
                if (e == 0) {
                    break;
                }
                
                i += 1;
                
                if (i >= typeEncodingLength) {
                    return nil;
                }
            }
            if (e > 0) {
                return nil; // 不合法
            }
            size_t const newLength = i + 1;
            if (newLength < 5) {
                return nil;
            }
            _encoding = [[NSString alloc] initWithBytes:typeEncoding length:newLength encoding:NSASCIIStringEncoding];
            if (newLength != typeEncodingLength) {
                typeEncoding = [_encoding cStringUsingEncoding:NSASCIIStringEncoding];
            }
            
            // 结构体名字
            i = 1;
            while (YES) {
                if (typeEncoding[i] == '=') {
                    break;
                }
                i += 1;
                if (i >= newLength) {
                    return nil; // typeEncoding 不合法
                }
            }
            if (i == 1) {
                return nil;
            }
            _name = [_encoding substringWithRange:NSMakeRange(1, i - 1)];
            
            NSMutableArray *members = [NSMutableArray array];
            
            _alignment = 1;
            // 定位 i 到等号后面第一个字符
            i += 1;
            // 最后一位是 } 结束字符
            size_t const membersEnd = newLength - 2;
            // 用 while 而不 do-while 是因为可能会有"空"结构体
            while (i <= membersEnd) {
                XZObjcType *member = [XZObjcType typeWithEncoding:typeEncoding + i];
                if (member == nil) {
                    return nil; // 遇到不合法的字符
                }
                [members addObject:member];
                
                // 对于结构体，默认字节对齐方式为成员中最大的那个。非默认情况需要由 provider 提供。
                _alignment = MAX(_alignment, member.alignment);
                
                i += member.encoding.length;
            };
            
            // 如果提供了自定义的 size 和 alignment 则使用自定的，否则根据默认规则计算。
            XZObjcRawAlignment const info = [XZObjcType alignmentForeEncoding:typeEncoding];
            if (info.size > 0) {
                _size = info.size;
                _sizeInBit = _size * 8;
                _alignment = info.alignment;
            } else if (members.count > 0) {
                _sizeInBit = 0;
                size_t const alignmentInBit = _alignment * 8;
                size_t availableBit = alignmentInBit; // 每个 alignment 中的可用位（字节）
                for (XZObjcType *subtype in members) {
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
                _size = sizeof(struct XZObjcTypeEmptyStruct);
                _sizeInBit = _size * 8;
                _alignment = _Alignof(struct XZObjcTypeEmptyStruct);
            }
            
            _members = members.copy;
            break;
        }
        case '(': { // (name=type...)
            _raw = XZObjcRawUnion;
            if (typeEncodingLength < 5) {
                return nil;
            }
            
            size_t i = 1;
            size_t e = 1;
            while (true) {
                switch (typeEncoding[i]) {
                    case '(':
                        e += 1;
                        break;
                    case ')':
                        e -= 1;
                        break;
                    default:
                        break;
                }
                
                if (e == 0) {
                    break;
                }
                
                i += 1;
                
                if (i >= typeEncodingLength) {
                    return nil;
                }
            }
            if (e > 0) {
                return nil;
            }
            size_t const newLength = i + 1;
            if (newLength < 5) {
                return nil;
            }
            _encoding = [[NSString alloc] initWithBytes:typeEncoding length:newLength encoding:NSASCIIStringEncoding];
            if (newLength != typeEncodingLength) {
                typeEncoding = [_encoding cStringUsingEncoding:NSASCIIStringEncoding];
            }
            
            // 结合体名字
            i = 1;
            while (YES) {
                if (typeEncoding[i] == '=') {
                    break;
                }
                i += 1;
                if (i >= newLength) {
                    return nil; // typeEncoding 不合法
                }
            }
            if (i == 1) {
                return nil;
            }
            _name = [_encoding substringWithRange:NSMakeRange(1, i)];
            
            NSMutableArray *members = [NSMutableArray array];
            
            _size = 0;
            _sizeInBit = 0;
            _alignment = 0;
            
            _alignment = 1;
            // 定位 i 到等号后面第一个字符
            i += 1;
            // 最后一位是 ) 结束字符
            size_t const membersEnd = newLength - 2;
            while (i < membersEnd) { // 用 while 而不 do-while 是因为可能会有"空"结合体
                XZObjcType *member = [XZObjcType typeWithEncoding:typeEncoding + i];
                if (member == nil) {
                    return nil;
                }
                [members addObject:member];
                
                _size = MAX(_size, member.size);
                _sizeInBit = MAX(_sizeInBit, member.sizeInBit);
                _alignment = MAX(_alignment, member.alignment);
                
                i += member.encoding.length;
            };
            
            if (members.count == 0) {
                _size = sizeof(union XZObjcTypeEmptyUnion);
                _sizeInBit = _size * 8;
                _alignment = _Alignof(union XZObjcTypeEmptyUnion);
            }
            
            _members = members.copy;
            break;
        }
        case 'b': {
            if (typeEncodingLength < 2) {
                return nil;
            }
            _raw = XZObjcRawBitField;
            _name = @"bit field";
            
            _sizeInBit = 0;
            size_t i = 1;
            while (i < typeEncodingLength) {
                const char number = typeEncoding[i];
                if (number < '0' || number > '9') {
                    break;
                }
                _sizeInBit = _sizeInBit * 10 + (number - '0');
                i += 1;
            };
            if (_sizeInBit == 0) {
                return nil; // typeEncoding 不合法
            }
            size_t const newLength = i;
            _encoding = [[NSString alloc] initWithBytes:typeEncoding length:newLength encoding:NSASCIIStringEncoding];
            if (newLength != typeEncodingLength) {
                typeEncoding = [_encoding cStringUsingEncoding:NSASCIIStringEncoding];
            }
                        
            _size = (_sizeInBit - 1) / 8 + 1;
            _alignment = 1;
            break;
        }
        case '^': {
            XZObjcType *member = [XZObjcType typeWithEncoding:typeEncoding + 1];
            _raw = XZObjcRawPointer;
            _name = [NSString stringWithFormat:@"%@ *", member.name];
            _size = sizeof(void *);
            _sizeInBit = _size * 8;
            _encoding  = [[NSString alloc] initWithBytes:typeEncoding length:member.encoding.length + 1 encoding:(NSASCIIStringEncoding)];
            _alignment = _Alignof(void *);
            _members  = @[member];
            break;
        }
        case '?': {
            _raw = XZObjcRawUnknown;
            _name = @"unknown";
            _size = sizeof(void *);
            _sizeInBit = _size * 8;
            _encoding  = @"?";
            _alignment = _Alignof(void *);
            break;
        }
        default: {
            return nil;
            break;
        }
    }
    return [self typeWithRaw:_raw name:_name qualifiers:qualifiers size:_size sizeInBit:_sizeInBit encoding:_encoding alignment:_alignment members:_members subtype:_subtype protocols:_protocols];
}

+ (instancetype)typeWithRaw:(XZObjcRaw)raw name:(NSString *)name qualifiers:(XZObjcQualifiers)qualifiers size:(size_t)size sizeInBit:(size_t)sizeInBit encoding:(NSString *)encoding alignment:(size_t)alignment members:(NSArray<XZObjcType *> *)members subtype:(Class)subtype protocols:(NSArray<Protocol *> *)protocols {
    return withStorage(^id(NSMutableDictionary<NSString *,NSMutableDictionary<NSNumber *,XZObjcType *> *> * const storage) {
        NSNumber * const key = @(qualifiers);
        XZObjcType *type = storage[encoding][key];
        if (type) {
            return type;
        }
        type = [[self alloc] initWithRaw:raw name:name qualifiers:qualifiers size:size sizeInBit:sizeInBit encoding:encoding alignment:alignment members:members subtype:subtype protocols:protocols];
        NSMutableDictionary *dictM = storage[encoding];
        if (dictM == nil) {
            dictM = [NSMutableDictionary dictionary];
            storage[encoding] = dictM;
        }
        dictM[key] = type;
        return type;
    });
}

- (instancetype)initWithRaw:(XZObjcRaw)raw name:(NSString *)name qualifiers:(XZObjcQualifiers)qualifiers size:(size_t)size sizeInBit:(size_t)sizeInBit encoding:(NSString *)encoding alignment:(size_t)alignment members:(NSArray<XZObjcType *> *)members subtype:(Class)subtype protocols:(NSArray<Protocol *> *)protocols {
    self = [super init];
    if (self) {
        _raw = raw;
        _name = name;
        _qualifiers = qualifiers;
        _size = size;
        _sizeInBit = sizeInBit;
        _encoding = encoding;
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
        [self.members enumerateObjectsUsingBlock:^(XZObjcType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@>,\n", obj, ((id)obj.subtype ?: obj.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        members = stringM;
    }
    
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: %lu, encoding: %@, size: %lu, alignment: %lu, subtype: %@, protocols: %@, members: %@>", NSStringFromClass(self.class), self, self.name, (unsigned long)self.raw, self.encoding, self.size, self.alignment, self.subtype, protocols, members];
}

#pragma mark - Provider

static NSMutableDictionary<NSString *, NSValue *> *_typeProviders = nil;

+ (void)setSize:(size_t)size alignment:(size_t)alignment forEncoding:(nonnull const char *)typeEncoding {
    NSParameterAssert(typeEncoding != NULL);
    
    NSString *name = [NSString stringWithCString:typeEncoding encoding:NSASCIIStringEncoding];
    
    XZObjcRawAlignment info = {size, alignment};
    if (_typeProviders == nil) {
        _typeProviders = [NSMutableDictionary dictionary];
    }
    _typeProviders[name] = [NSValue valueWithBytes:&info objCType:@encode(XZObjcRawAlignment)];
}

+ (XZObjcRawAlignment)alignmentForeEncoding:(const char *)typeEncoding {
    XZObjcRawAlignment alignment = {0, 0};
    NSString * const key = [NSString stringWithCString:typeEncoding encoding:NSASCIIStringEncoding];
    [_typeProviders[key] getValue:&alignment];
    return alignment;
}

@end
