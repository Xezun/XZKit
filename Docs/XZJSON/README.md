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

## 如何使用

> XZJSON 基于 [YYModel](https://github.com/ibireme/YYModel) 打造，主要解决 YYModel 不再维护的问题。

> XZJSON 采用 “工具类” + “协议” 的方式实现，这与 YYModel 设计思路不同。

1、JSON 数据 Model 化

```objc
Model *model = [XZJSON decode:data options:(NSJSONReadingAllowFragments) class:[Model class]];
```

2、Model 对象 JSON 序列化

```objc
NSData *json = [XZJSON encode:model options:NSJSONWritingPrettyPrinted error:nil];
```

3、其它功能

- Model 属性与 JSON 键映射

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

- 不透明对象类型映射

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

## Author

Xezun, developer@xezun.com

## License

XZJSON is available under the MIT license. See the LICENSE file for more info.
