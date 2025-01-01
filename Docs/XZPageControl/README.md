# XZPageControl

[![Version](https://img.shields.io/cocoapods/v/XZPageControl.svg?style=flat)](https://cocoapods.org/pods/XZPageControl)
[![License](https://img.shields.io/cocoapods/l/XZPageControl.svg?style=flat)](https://cocoapods.org/pods/XZPageControl)
[![Platform](https://img.shields.io/cocoapods/p/XZPageControl.svg?style=flat)](https://cocoapods.org/pods/XZPageControl)

## 示例

运行示例项目，请在拉取代码后，先在 Pods 目录执行 `pod install` 命令。

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## Requirements

iOS 11.0, Xcode 14.0

## Installation

`XZPageControl` is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZPageControl'
```

## 如何使用

`XZPageControl` 是 `UIControl` 类控件，并且支持在 StoryBoard 或 xib 中使用。

```objc
// 创建视图
XZPageControl *pageControl = [[XZPageControl alloc] initWithFrame:CGRectMake(0, 200, 375, 50.0)];
[self.view addSubview:pageControl];
```

设置`numberOfPages`属性就可以正常工作了，还可以通过`currentPage`属性设置初始值。

```objc
pageControl.numberOfPages = 10;
pageControl.currentPage = 5;  // 默认展示第 5 页
```

### 处理事件

通过 `target-action` 机制，绑定 `UIControlEventValueChanged` 事件。

```objc
// 绑定事件
[pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:(UIControlEventValueChanged)];

// 处理事件
- (void)pageControlValueChanged:(XZPageControl *)pageControl {
    NSLog(@"currentPage: %ld", pageControl.currentPage);
}
```

### 自定义样式

指示器默认为白色圆点，当前页指示器为灰色圆点。通过`fillColor`和`strokeColor`可以自定义指示器颜色。

```objc
pageControl.indicatorFillColor          = UIColor.grayColor;
pageControl.indicatorStrokeColor        = UIColor.grayColor;
pageControl.currentIndicatorFillColor   = UIColor.redColor;
pageControl.currentIndicatorStrokeColor = UIColor.redColor;
```

通过`shape`可以自定义指示器形状。

```objc
// 将当前页的指示器改为圆角矩形。
pageControl.currentIndicatorShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(8, 12.0, 14.0, 6.0) cornerRadius:3.0];
```

指示器也可以是图片，需要注意的是，如果指定了图片，那么上述的`shape`、`fillColor`、`strokeColor`设置将失效。

```objc
pageControl.indicatorImage = [UIImage imageNamed:@"normal"];
pageControl.currentIndicatorImage = [UIImage imageNamed:@"current"];
```

以上方式，都可以单独设置每一个指示器，使每个指示器都有不一样的外观。不过，需要注意的是，只能为已存在的指示器指定样式。

```objc
[pageControl setIndicatorFillColor:UIColor.redColor forPage:0];
```

如果默认指示器的功能不能满足要求，还通过`XZPageControlIndicator`协议，自定义指示器视图，完全自定义指示器的外观。

```objc
@protocol XZPageControlIndicator <NSObject>
@property (nonatomic, setter=setCurrent:) BOOL isCurrent;
@optional
@property (nonatomic, strong, nullable) UIColor *strokeColor;
@property (nonatomic, strong, nullable) UIColor *currentStrokeColor;

@property (nonatomic, strong, nullable) UIColor *fillColor;
@property (nonatomic, strong, nullable) UIColor *currentFillColor;

@property (nonatomic, copy, nullable) UIBezierPath *shape;
@property (nonatomic, copy, nullable) UIBezierPath *currentShape;

@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *currentImage;
@end
```

#### 其它特性

通过`contentMode`属性，可以改变指示器的布局方式。其中，

- UIViewContentModeLeft: 居左
- UIViewContentModeRight: 居右
- UIViewContentModeCenter及其它: 居中

```objc
// 指示器居右排列
pageControl.contentMode = UIViewContentModeRight; 
```

通过`layoutMargins`可以限制指示器的布局区域，指示器尽量不布局在`layoutMargins`所表示的区域。

```obj
// 左边 50 区域内不会布局指示器
pageControl.layoutMargins = UIEdgeInsetsMake(0, 50, 0, 0);
```

#### 指示器布局规则

1. 指示器视图布局在 XZPageControl 视图之内，除`layoutMargins`之外的矩形区域。
2. 指示器高度与矩形区域同高，宽度受`maximumIndicatorSpacing`属性控制，默认 30 点。
3. 指示器视图之间无间距，在指示器视图内，可以自由定义指示器的外观。
4. 指示器可以超出指示器视图，除非设计好规则，否则可能会发生重叠。
5. 指示器视图在 XZPageControl 布局，会自动适配当前的布局方向。

## 版本计划

1. 渐变式过渡效果

## Author

Xezun, developer@xezun.com

## License

XZPageControl is available under the MIT license. See the LICENSE file for more info.
