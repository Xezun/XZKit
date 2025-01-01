# XZPageView

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZPageView)
[![Version](https://img.shields.io/cocoapods/v/XZPageView.svg?style=flat)](https://cocoapods.org/pods/XZPageView)
[![License](https://img.shields.io/cocoapods/l/XZPageView.svg?style=flat)](https://cocoapods.org/pods/XZPageView)
[![Platform](https://img.shields.io/cocoapods/p/XZPageView.svg?style=flat)](https://cocoapods.org/pods/XZPageView)

## Example

要运行示例项目，请在拉取代码后，先在 Pods 目录执行`pod install`命令。

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## Requirements

iOS 11.0, Xcode 14.0

## Installation

XZPageView is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZPageView'
```

## 如何使用

XZPageView 是一种横向整体翻页的视图组件，常见于轮播图，也可用于多 Tab 页面。

XZPageView 使用复用机制，只需两个 UIImageView 控件即可实现无限轮播，可以减少内存使用。

XZPageView 使用数据源机制，可以提供更大的自定义自由度，以适应各种开发需求。

### 1、示例代码

```objc
@implementation ViewController
// 创建视图
- (void)viewDidLoad {
    [super viewDidLoad];

    XZPageView *pageView = [[XZPageView alloc] initWithFrame:CGRectMake(0, 0, 375.0, 150.0)];
    [self.view addSubview:pageView];
    
    pageView.delegate   = self;
    pageView.dataSource = self;
}

// 实现数据源方法

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    return self.imageURLs.count;
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(UIImageView *)reusingView {
    if (reusingView == nil) {
        reusingView = [[UIImageView alloc] initWithFrame:pageView.bounds];
        // config the UIImageView here
    }
    [reusingView sd_setImageWithURL:self.imageURLs[index]];
    return reusingView;
}

- (nullable UIView *)pageView:(XZPageView *)pageView prepareForReusingView:(UIImageView *)reusingView {
    reusingView.image = nil; 
    return reusingView;
}
@end
```

### 2、支持自动轮播及循环轮播

```objc
self.pageView.isLoopable = YES;
self.pageView.autoPagingInterval = 3.0;
```

### 3、支持垂直翻页

```objc
self.pageView.orientation = XZPageViewOrientationVertical;
```

### 4、支持播报转场进度

```objc
- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index {
    NSLog(@"didShowPageAtIndex: %f", transition);
}

- (void)pageView:(XZPageView *)pageView didTurnPageWithTransition:(CGFloat)transition {
    NSLog(@"didTurnPageWithTransition: %f", transition);
}
```

## 版本计划

1. XZPageViewController

## Author

Xezun, developer@xezun.com

## License

XZPageView is available under the MIT license. See the LICENSE file for more info.
