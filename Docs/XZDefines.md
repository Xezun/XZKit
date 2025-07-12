# XZDefines

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZDefines)
[![Version](https://img.shields.io/cocoapods/v/XZDefines.svg?style=flat)](https://cocoapods.org/pods/XZDefines)
[![License](https://img.shields.io/cocoapods/l/XZDefines.svg?style=flat)](https://cocoapods.org/pods/XZDefines)
[![Platform](https://img.shields.io/cocoapods/p/XZDefines.svg?style=flat)](https://cocoapods.org/pods/XZDefines)

XZDefines 是 XZKit 基础定义部分，包含一些开发常用的基础函数、宏定义和运行时基础函数等。

## Example

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## Requirements

iOS 11.0, Xcode 14.0

## Installation

XZDefines is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZDefines'
```

## 功能列表

### 1、XZMacro - 高级宏定义

- `xz_macro_keyize`：让宏变成类似于`@selector()`形式的关键字宏。

```objc
// use the xz_macro_keyize to define a macro
#define log(...) xz_macro_keyize NSLog(__VA_ARGS__)

// Use the macro like a objc keyword
@log(@"foobar");
```

- `xz_macro_paste(A, B)`： 直接将 A 和 B 拼接一起，主要用于设计高级宏。

- `xz_macro_args_map(MACRO, SEP, ...)`：遍历宏参数，并对每个参数逐个应用 `MACRO(index, param)` 宏，每次结果用 `SEP` 分割。

```objc
// define the macro
#define log(index, value)   NSLog(@"The value %ld is %@.", (long)index, value)
#define logAll(...)         xz_macro_args_map(log, ;, __VA_ARGS__)

// use the macro
NSString *foo = @"foo";
NSString *bar = @"bar";
logAll(foo, bar);

// The console outputs:
// The value 0 is foo.
// The value 1 is bar.
```

- `XZ_ATTR_OVERLOAD`：让函数可以重载。

```objc
// 在 XZExtensions 中，有如下使用 RGB 创建颜色的便利函数，就使用了 XZ_ATTR_OVERLOAD 宏。
UIColor *rgba(UInt8 red, UInt8 green, UInt8 blue, UInt8 alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha / 255.0];
}

UIColor *rgba(UInt32 value) XZ_ATTR_OVERLOAD {
    return rgba(value >> 24, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
}

NSLog(@"%@", rgba(0xAABBCCDD));             // UIExtendedSRGBColorSpace 0.666667 0.733333 0.8 0.866667
NSLog(@"%@", rgba(0xAA, 0xBB, 0xCC, 0xDD)); // UIExtendedSRGBColorSpace 0.666667 0.733333 0.8 0.866667
```

- `XZ_ATTR_INTERNAL`：标记函数为内部函数。

- `XZ_DEPRECATED(message)`：标记API废弃。

- `XZ_CONST`、`XZ_READONLY`、`XZ_UNAVAILABLE`：标记仅 XZKit 内部可写或可用的 API 或函数或类。

- `enweak`、`deweak`：变量的弱引用化和强引用化，支持多个参数。

```objc
enweak(self, foo, bar);
self.block = ^{
    deweak(self, foo, bar);
    // from now, the block will not own the self foo bar
};
```

### 2、XZDefer - 延迟执行

在使用需要成对搭配使用的方法时，使用 `defer` 可以将关闭语句写在前面，这样就可以避免忘记。

```objc
UIGraphicsBeginImageContext(CGSizeMake(100, 100));
defer(^{
    UIGraphicsEndImageContext();
});

// draw the image
```

### 3、XZEmpty - 空值处理

- `isNonEmpty(value)` 非空判断

在 OC 开发中，经常要用到非空判断，现在有了便利函数。

```objc
// 具体类型的变量，可以直接进行该类型的判断
NSString *aString;
if (isNonEmpty(aString)) {
    NSLog(@"aString is a non-emtpy string");
}
NSArray *anArray;
if (isNonEmpty(anArray)) {
    NSLog(@"anArray is a non-emtpy array");
}

// id 类型的变量，需要使用强转指定要检测的数据类型。
id foo;
if (isNonEmpty((NSString *)foo)) {
    NSLog(@"foo is a non-emtpy string");
}
if (isNonEmpty((NSDictionary *)foo)) {
    NSLog(@"foo is a non-emtpy NSDictionary");
}
if (isNonEmpty(foo)) {
    NSLog(@"foo is a not nil and not NSNull value");
}
```

- `asNonEmpty(value, defaultValue)` 非空默认值

在开发中，遇到空的或不合法的数据，我们常常希望使用默认值，以避免逻辑问题。

```objc
// 在字典中取值时，由于可能会取到空值，所以不得不进行非空判断，设计默认值。
NSDictionary *dict;
NSString *name = dict[@"name"];
if (![name isKindOfClass:NSString.class] || name.length == 0) {
    name = @"Visitor";
}

// 使用 asNonEmpty 可以简化上面的 if 语句。
NSString *name = asNonEmpty(dict[@"name"], @"Visitor");
```

### 4、XZRuntime - 运行时便利函数

#### 4.1 通用方法

- `xz_objc_class_getMethod` - 获取类自身的实例方法。
- `xz_objc_class_enumerateMethods` - 遍历类自身的实例方法。
- `xz_objc_class_enumerateVariables` - 遍历类自身的实例变量。
- `xz_objc_class_getVariableNames` - 获取类自身实例变量名称。
- `xz_objc_class_exchangeMethods` - 类交换自己方法的实现。
- `xz_objc_class_addMethod` - 为类添加方法。
- `xz_objc_class_addMethodWithBlock` - 为类添加方法。

#### 4.2 动态创建类

- `xz_objc_createClassWithName` - 派生新类。
- `xz_objc_createClass` - 派生子类。
- `xz_objc_class_copyMethod` - 复制单个方法。
- `xz_objc_class_copyMethods` - 复制所有方法。

### 5、XZUtils - 常用工具函数

- `XZVersionStringCompare` - 版本号比较函数，方便比较两个版本号的大小。
- `XZTimestamp` - 获取当前时间戳，精确到微秒。

## Author

Xezun, developer@xezun.com

## License

XZDefines is available under the MIT license. See the LICENSE file for more info.

