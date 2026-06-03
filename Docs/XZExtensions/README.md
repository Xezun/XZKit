# XZExtensions

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZExtensions)
[![Version](https://img.shields.io/cocoapods/v/XZExtensions.svg?style=flat)](https://cocoapods.org/pods/XZExtensions)
[![License](https://img.shields.io/cocoapods/l/XZExtensions.svg?style=flat)](https://cocoapods.org/pods/XZExtensions)
[![Platform](https://img.shields.io/cocoapods/p/XZExtensions.svg?style=flat)](https://cocoapods.org/pods/XZExtensions)

本库是对原生框架的拓展，为原生类添加一些常用方法和属性，以降低代码重复，提高开发效率。

## Example

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## Requirements

iOS 11.0, Xcode 14.0

## Installation

XZExtensions is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZKit/XZExtensions'
```

## 功能特性

### CAAnimation

1. 抖动动画

```objc
CAAnimation *animation = [CAAnimation xz_vibrateAnimationWithAmplitudeX:3 y:0 z:0];
```

### CALayer

暂无。

### NSArray

1. 判断是否包含重复元素

```objc
NSArray *array = @[@"1", @"2"];
NSLog(@"是否包含重复元素：%@", [array xz_containsEqualObjects] ? @"包含" : @"不包含"); // 不包含
array = @[@"1", @"2", @"1"];
NSLog(@"是否包含重复元素：%@", [array xz_containsEqualObjects] ? @"包含" : @"不包含"); // 包含
```

2. 高阶函数

```objc
NSObject *results = [array xz_map:^id _Nonnull(id  _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
    return [NSString stringWithFormat:@"%ld => %@", idx, obj];
}];

[array xz_compactMap:^id _Nullable(id  _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
    if (idx % 2 == 0) {
        return nil;
    }
    return [NSString stringWithFormat:@"%ld => %@", idx, obj];
}];

[array xz_reduce:@(0) next:^id _Nullable(NSNumber *result, NSNumber *obj, NSInteger idx, BOOL * _Nonnull stop) {
    return @(result.integerValue + obj.integerValue);
}];

NSArray *users = [array xz_first:^BOOL(id  _Nonnull obj, NSInteger idx) {
    return [obj isKindOfClass:User.class];
}];

NSArray *students = [array xz_filter:^BOOL(id  _Nonnull obj, NSInteger idx) {
    return [obj isKindOfClass:Student.class];
}];
```

3. 差异分析

```objc
NSArray *array1 = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
NSArray *array2 = @[@"E", @"B", @"G", @"H", @"A", @"I", @"J"];
NSLog(@"差异分析：%@ => %@", [NSString xz_stringWithJSONObject:array1], [NSString xz_stringWithJSONObject:array2]);
NSMutableIndexSet   *inserts = [NSMutableIndexSet indexSet];
NSMutableIndexSet   *deletes = [NSMutableIndexSet indexSet];
NSMutableIndexSet   *remains = [NSMutableIndexSet indexSet];
NSMutableDictionary *changes = [NSMutableDictionary dictionary];
[array2 xz_differenceFromArray:array1 inserts:inserts deletes:deletes changes:changes remains:remains];

NSLog(@"插入的元素：%@", [NSString xz_stringWithJSONObject:[inserts xz_map:^id _Nonnull(NSInteger idx, BOOL * _Nonnull stop) {
    return @(idx);
}]]); // [3,5,6]

NSLog(@"删除的元素：%@", [NSString xz_stringWithJSONObject:[deletes xz_map:^id _Nonnull(NSInteger idx, BOOL * _Nonnull stop) {
    return @(idx);
}]]); // [2,3,5]

NSLog(@"移动的元素：%@", [NSString xz_stringWithJSONObject:[changes xz_map:^id _Nonnull(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    return [NSString stringWithFormat:@"%@ => %@", obj, key];
}]]); // ["4 => 0","0 => 4","6 => 2"]

NSLog(@"未变的元素：%@", [NSString xz_stringWithJSONObject:[remains xz_map:^id _Nonnull(NSInteger idx, BOOL * _Nonnull stop) {
    return @(idx);
}]]); // [1]
```

4. JSON 支持

```objc
NSArray *array = [NSArray xz_arrayWithJSON:@"[1, 2, 3]"];
```

### NSAttributedString

仅给包含字形的文本添加字体。

```objc
NSMutableAttributedString *attributedStringM = [[NSMutableAttributedString alloc] initWithAttributedString:self];
[attributedStringM xz_addAttributesForCharactersOfGlyphsInFont:font];
```

### NSBundle

1. 获取版本号、构建版本号

### NSCharacterSet

1. 符合通用规范的 URI/URIComponent 字符集

### NSData

1. 十六进制编码

### NSIndexSet

1. reduce/map/compactMap 高级函数

### NSObject

1. 遍历 keyPath 及相关方法


### NSString

1. 查找字体是否包含
2. 取 integer/float 值
4. UIR 编码
6. 十六进制编码
7. JSON


### UIApplication

1. 状态栏


### UIBezierPath

1. 画五角星


### UIColor

1. RGB 颜色

### UIDevice

1. 获取设备型号、主板型号

### UIFont

1. 注册字体
2. 判断字体是否包含字形

### UIImage

1. 修改透明度
2. 修改宣染色
3. 修改亮度
4. 修改色阶

### UIView

1. 遍历层级关系、输出
2. 截图

### UIViewController

1. 状态栏控制

同一页面中，当状态栏需要动态变化时，需要额外定义实例变量来记录状态，但是现在，状态栏的样式可以直接通过属性`xz_prefersStatusBarHidden`和属性`xz_preferredStatusBarStyle`进行配置。

```objc
self.xz_prefersStatusBarHidden = NO;
self.xz_preferredStatusBarStyle = UIStatusBarStyleLightContent;
```




## Author

Xezun, developer@xezun.com

## License

XZExtensions is available under the MIT license. See the LICENSE file for more info.
