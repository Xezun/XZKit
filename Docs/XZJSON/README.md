# XZJSON

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZJSON)
[![Version](https://img.shields.io/cocoapods/v/XZJSON.svg?style=flat)](https://cocoapods.org/pods/XZJSON)
[![License](https://img.shields.io/cocoapods/l/XZJSON.svg?style=flat)](https://cocoapods.org/pods/XZJSON)
[![Platform](https://img.shields.io/cocoapods/p/XZJSON.svg?style=flat)](https://cocoapods.org/pods/XZJSON)

## 示例项目 Example

要运行示例项目，请在拉取代码后，先在`Pods`目录执行`pod install`命令。

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## 环境需求 Requirements

iOS 11.0, Xcode 14.0

## 如何安装 Installation

推荐使用 [CocoaPods](https://cocoapods.org) 安装 XZJSON 组件，在`Podfile`文件中添加下面这行代码即可。

XZJSON is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZJSON'
```

## 特点

1. 借鉴 [YYModel](https://github.com/ibireme/YYModel) 设计思路打造，性能与 YYModel 几乎相同。

示例项目移植了 YYModel 提供的跑分代码，执行结果如下。

```
Device: iPhone SE 2
----------------------
Benchmark (10000 times):
GHUser             from json    to json    archive
JSON(*):              113.66      88.56   
YYModel(#):            46.00      64.99     516.37
XZJSON(#):             61.90      74.67     592.33
----------------------
----------------------
Benchmark (1000 times):
WeiboStatus     from json    to json    archive
YYModel:           186.33     124.33     601.60
XZJSON:            200.71     137.17     656.07
----------------------
----------------------
The property is NSString, but the json value is number:
YYModel:         ✅ property is NSTaggedPointerString
XZJSON:          ✅ property is NSTaggedPointerString
----------------------
The property is int, but the json value is string:
YYModel:         ✅ property is 100
XZJSON:          ✅ property is 100
----------------------
The property is NSDate, and the json value is string:
YYModel:         ✅ property is __NSTaggedDate
XZJSON:          ✅ property is __NSTaggedDate
----------------------
The property is NSValue, and the json value is string:
YYModel:         ✅ property is nil
XZJSON:          ✅ property is nil
```

2. 为方便接入，XZJSON 采用 “工具类” + “协议” 的方式实现，迁移到 XZJSON 时，可以保持现有 API 不变，将方法实现替换即可。

比如，在项目中，已经大量使用 YYModel 提供的 `+yy_modelWithJSON:` 方法生成模型。

```objc
+ (instancetype)yy_modelWithJSON:(id)json {
    NSDictionary *dic = [self _yy_dictionaryWithJSON:json];
    return [self yy_modelWithDictionary:dic];
}
```

那么仅需要将 YYModel 这个方法实现替换为如下即可。

```objc
+ (instancetype)yy_modelWithJSON:(id)json {
    return [XZJSON decode:json options:NSJSONReadingAllowFragments class:[self class]];
}
```

当然，如果在业务中，项目对三方接口进行了屏蔽，那么修改屏蔽的中间层即可。

## 示例

1、数据转模型

```objc
Model *model = [XZJSON decode:data options:NSJSONReadingAllowFragments class:[Model class]];
```

2、模型转数据

```objc
NSData *json = [XZJSON encode:model options:NSJSONWritingPrettyPrinted error:nil];
```

3、其它功能

- 自定义模型属性与数据键值的映射关系

```objc
+ (NSDictionary<NSString *,id> *)mappingJSONCodingKeys {
    return @{
        @"identifier": @"id",
        @"name": @"info.name", // 映射 keyPath
        @"age": @[@"age", @"info.age"]
        @"foobar": @"foo\\.bar" // 映射 JSON 的 "foo.bar" 键，而不是 keyPath
    };
}
```

- 不透明对象或集合元素类型映射

```objc
+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{
        @"students": [Student class]
    };
}
```

- 自定义模型化过程、数据校验

```objc
- (instancetype)initWithJSONDictionary:(NSDictionary *)JSON {
    // 调用指定初始化方法。
    self = [self init];
    if (self != nil) {
        // 使用 XZJSON 进行初始化。
        [XZJSON object:self decodeWithDictionary:JSON];
        
        // 处理自定义逻辑：关联学生和老师
        [self.students enumerateObjectsUsingBlock:^(Example001Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.teacher = self;
        }];
    }
    return self;
}
```

- 白名单、黑名单

```objc
+ (NSArray<NSString *> *)allowedJSONCodingKeys {
    return nil; // allow all
}

+ (NSArray<NSString *> *)blockedJSONCodingKeys {
    return @[@"teacher"];
}
```

- 模型转发

```objc
+ (nullable Class)forwardingClassForJSONDictionary:(NSDictionary *)JSON {
    // 在此方法中，可通过对 JSON 数据进行判断，返回适合的模型进行解析数据。
    return SomeModelClass;
}
```

- 前置数据校验。

```objc
+ (nullable NSDictionary *)canDecodeFromJSONDictionary:(NSDictionary *)JSON {
    // 在此方法中，可校验或修改数据，返回 nil 表示数据不合法，停止模型化
}
```

- 自定义 JSON 序列化。

```objc
- (nullable NSDictionary *)encodeIntoJSONDictionary:(NSMutableDictionary *)dictionary {
    [XZJSON object:self encodeIntoDictionary:dictionary];
    dictionary[@"date"] = @(NSDate.date.timeIntervalSince1970); // 自定义：向序列化数据中，加入一个时间戳
    return dictionary;
}
```

- 模型描述

```objc
[XZJSON modelDescription:model];
```

- 归档与解档

```objc
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [XZJSON model:self decodeWithCoder:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [XZJSON model:self encodeWithCoder:coder];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}
```

- 特殊属性的 encoding/decoding

示例1，C 指针的内存完全是由开发者管理，因此需要自定义 encoding/decoding 过程。

```objc
/// c 字符串。
@property (nonatomic) char *foo;

- (void)dealloc {
    if (_foo) {
        free(_foo);
        _foo = NULL;
    }
}

- (void)JSONDecodeValue:(id)valueOrCoder forKey:(NSString *)key {
    if ([key isEqualToString:@"foo"]) {
        if ([valueOrCoder isKindOfClass:NSCoder.class]) {
            // 如果使用了 XZJSON 的存档方法，那么在这里也可以自定义存档的解档过程。
            valueOrCoder = [(NSCoder *)valueOrCoder decodeObjectOfClass:NSString.class forKey:key];
        }
        NSString *value = valueOrCoder;
        if ([value isKindOfClass:NSString.class]) {
            NSUInteger length = [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
            if (_foo) {
                _foo = realloc(_foo, length * sizeof(char));
            } else {
                _foo = calloc(length, sizeof(char));
            }
            memcpy(_foo, [value cStringUsingEncoding:NSASCIIStringEncoding], length);
        }
    }
}

- (id<NSCoding>)JSONEncodeValueForKey:(NSString *)key {
    if ([key isEqualToString:@"foo"]) {
        // c 字符串的自定义 encode 过程，返回值也会用于 存档 过程。
        return _foo ? [NSString stringWithCString:_foo encoding:NSASCIIStringEncoding] : nil;
    }
    return nil;
}
``` 

2. 自定义结构体的自定义 encoding/decoding 过程。

```objc
typedef struct Example05Struct {
    int a;
    float b;
    double c;
} Example05Struct;

@property (nonatomic) Example05Struct bar;

- (void)JSONDecodeValue:(id)valueOrCoder forKey:(NSString *)key {
    if ([key isEqualToString:@"bar"]) {
        if ([valueOrCoder isKindOfClass:NSCoder.class]) {
            valueOrCoder = [(NSCoder *)valueOrCoder decodeObjectOfClass:NSString.class forKey:key];
        }
        NSString *value = valueOrCoder;
        if ([value isKindOfClass:NSString.class]) {
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
            NSArray *parts = [value componentsSeparatedByString:@", "];
            if (parts.count == 3) {
                int a = [parts[0] intValue];
                float b = [parts[1] floatValue];
                double c = [parts[2] doubleValue];
                _bar = (Example05Struct){a, b, c};
            }
        }
    }
}

- (id)JSONEncodeValueForKey:(NSString *)key {
    if ([key isEqualToString:@"bar"]) {
        return [NSString stringWithFormat:@"{%d, %G, %G}", _bar.a, _bar.b, _bar.c];
    }
    return nil;
}
```

## Author

Xezun, developer@xezun.com

## License

XZJSON is available under the MIT license. See the LICENSE file for more info.
