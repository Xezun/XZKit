# XZRefresh

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZRefresh)
[![Version](https://img.shields.io/cocoapods/v/XZRefresh.svg?style=flat)](https://cocoapods.org/pods/XZRefresh)
[![License](https://img.shields.io/cocoapods/l/XZRefresh.svg?style=flat)](https://cocoapods.org/pods/XZRefresh)
[![Platform](https://img.shields.io/cocoapods/p/XZRefresh.svg?style=flat)](https://cocoapods.org/pods/XZRefresh)

迄今为止 iOS 最流畅的下拉刷新、上拉加载组件。

## 设计背景

在实际使用过程中，其它三方下拉刷新组件，在某些极端条件下，总是会有卡顿或交互不畅的情形。在深入研究源代码之后发现造成卡顿的原因，是因为这些组件，都或多或少的都干预了 `UIScrollView` 滚动过程。

所以，在设计时 `XZRefresh` 采用了监听 `UIScrollViewDelegate` 方法，在 `UIScrollView` 滚动流程中，不改变其滚动状态，只监听其变化，从而更新下拉刷新的状态，将对 `UIScrollView` 的滚动影响降到最小。

## 示例工程 Example

要运行示例工程，请在拉取代码后，先在 `Pods` 目录下执行 `pod install` 命令。

To run the example project, clone the repo, and run `pod install` from the `Pods` directory first.

## 环境需求 Requirements

iOS 12.0, Xcode 14.0

## 安装使用 Installation

推荐使用 [CocoaPods](https://cocoapods.org) 安装 `XZRefresh` 组件。

`XZRefresh` is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZRefresh'
```

## 效果展示

`XZRefresh` 内置了两种刷新效果。

- 下拉刷新默认效果：XZRefreshStyle1View

<img src="./Images/refresh-style-1.gif" width="75" height="50" /> 

- 上拉加载默认效果：XZRefreshStyle2View

<img src="./Images/refresh-style-2.gif" width="75" height="50" />

## 如何使用

### 创建组件

通过 `xz_headerRefreshView` 或 `xz_footerRefreshView` 属性可以设置刷新控件。另外 `XZRefresh` 提供了默认控件，通过懒加载可自动创建。

```objc
// 使用默认的刷新控件
[self.tableView xz_headerRefreshView];
```

通过继承`XZRefreshView`可自定义刷新效果，具体可参考 `XZRefreshStyle1View` 或 `XZRefreshStyle2View` 。

```objc
// 使用创建的刷新控件
self.tableView.xz_headerRefreshView = [[XZRefreshStyle2View alloc] init];
```

### 处理事件

默认情况下，`XZRefresh` 使用 `UIScrollView.delegate` 作为代理，实现协议 `XZRefreshDelegate` 的方法即可处理事件。

```objc
// 下拉刷新事件
- (void)scrollView:(UIScrollView *)scrollView headerDidBeginRefreshing:(XZRefreshView *)refreshView {
    // handle the pull down refreshing
    [refreshView endAnimating];
}
// 上拉加载事件
- (void)scrollView:(UIScrollView *)scrollView footerDidBeginRefreshing:(XZRefreshView *)refreshView {
    // handle the pull up refreshing
    [refreshView endAnimating];
}
```

可以通过 `XZRefreshView` 的 `delegate` 属性，指定事件的接收对象。

```objc
self.tableView.xz_headerRefreshView.delegate = theReceiverObject;
```

调用唤起刷新的方法，不会触发事件方法。

```objc
[self.tableView.xz_headerRefreshView beginRefreshing];
[self.tableView.xz_footerRefreshView beginRefreshing:YES completion:^(BOOL finished) {
    // the footer refreshing view is animating now
}];
```

### 适配布局

通过 `XZRefreshView` 的 `adjustment` 属性，可以设置适配 `UIScrollView` 边距的方式，支持三种模式：

- XZRefreshAdjustmentAutomatic：适配 `UIScrollView.adjustedContentInset` 边距。
- XZRefreshAdjustmentNormal：适配 `UIScrollView.contentInset` 边距。
- XZRefreshAdjustmentNone：不适配边距。

```objc
self.tableView.xz_footerRefreshView.adjustment = XZRefreshAdjustmentNone;
```

除适配模式外，还可以通过 `offset` 属性，来调整刷新视图的位置。

```
self.tableView.xz_headerRefreshView.offset = 50; // 向上偏移 50 点
self.tableView.xz_footerRefreshView.offset = 50; // 向下偏移 50 点
```

另外，尾部刷新视图，始终布局在 `UIScrollView` 的尾部，即使在 `contentSize.height < bounds.size.height` 时也是。

### 自动刷新

通过 `automaticRefreshDistance` 属性，可以指定触发自动刷新的距离。

```objc
// 当页面滚动距离底部 50 时，自动触发底部刷新。
self.tableView.xz_footerRefreshView.automaticRefreshDistance = 50;
```

## 自定义

下拉刷新之后继续下拉进入二级页面，是目前实际应用比较广泛的功能，通过 `XZRefresh` 自定义刷新控件可以很容易实现该类效果。

```objc
- (void)scrollView:(UIScrollView *)scrollView didScrollRefreshing:(CGFloat)distance {
    if (distance < 50) {
        // 展示下拉刷新的过程
    } else if (distance < 100) {
        // 松手进入刷新，或继续下拉进入二楼
    } else if (distance < 150) {
        // 松手进入二楼
    } else {
        // 直接进入二楼
        [self.delegate enterSecondFloor:YES];
    }
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance {
    if (distance < 50) {
        return NO;
    }
    if (distance < 100) {
        return YES; // 进入刷新状态
    }
    if (distance < 150) {
        [self.delegate enterSecondFloor:NO]; // 松手进入二楼
        return NO;
    }
    return NO; // 直接进入二楼
}


/// 处理事件
- (void)enterSecondFloor:(BOOL)type {
    UIViewController *vc = UIViewController.new;
    if (type) { // 如有必要，可以为两种不同交互方式，设计不同的转场效果
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

```

## Author

Xezun, developer@xezun.com

## License

XZRefresh is available under the MIT license. See the LICENSE file for more info.
