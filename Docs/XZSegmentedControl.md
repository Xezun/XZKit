# XZSegmentedControl

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZSegmentedControl)
[![Version](https://img.shields.io/cocoapods/v/XZSegmentedControl.svg?style=flat)](https://cocoapods.org/pods/XZSegmentedControl)
[![License](https://img.shields.io/cocoapods/l/XZSegmentedControl.svg?style=flat)](https://cocoapods.org/pods/XZSegmentedControl)
[![Platform](https://img.shields.io/cocoapods/p/XZSegmentedControl.svg?style=flat)](https://cocoapods.org/pods/XZSegmentedControl)

一款支持高度自定义的分段式控件，基于 UICollectionView 打造，可用于横向或纵向的菜单视图。

```swift
let control = XZSegmentedControl.init(frame: CGRect(x: 0, y: 0, width: 375, height: 50), direction: .horizontal)
self.view.addSubview(control)

control.titles = ["标题一", "标题二"]
control.titleColor = .black
control.selectedTitleColor = .red

control.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## Requirements

iOS 11.0, Xcode 14.0

## Installation

XZSegmentedControl is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZSegmentedControl'
```

## 功能特性

### 1、支持横向和纵向滚动

```swift
segmentedControl.direction = .horizontal
segmentedControl.direction = .vertical
```

### 2、支持在头尾添加自定义视图

```swift
let headerView = UIButton.init(type: .system)
segmentedControl?.headerView = headerView

let footerView = UIButton.init(type: .system)
segmentedControl.footerView = footerView
```

### 3、多种指示器样式，以及自定义指示器

- 内置两种基础样式，且支持设置颜色、大小、图片

```swift
segmentedControl.indicatorStyle = .markLine
segmentedControl.indicatorStyle = .noteLine

segmentedControl.indicatorColor = .red
segmentedControl.indicatorSize  = CGSize(width: 20, height: 20)
segmentedControl.indicatorImage = UIImage(named: "arrow")
```

- 自定义指示器

```swift
segmentedControl.indicatorStyle = .custom
segmentedControl.indicatorClass = ExampleSegmentedControlIndicatorView.self
```

### 4、指示器支持交互性转场

```swift
segmentedControl.updateInteractiveTransition(transition)
```

### 5、支持自定义 segment 视图

继承 `XZSegmentedControlSegment` 即可自定义 segment 视图。

```swift
segmentedControl.register(ExampleSegmentedControlSegment.self, forSegmentWithReuseIdentifier: "indicator")
```

## Author

Xezun, developer@xezun.com

## License

XZSegmentedControl is available under the MIT license. See the LICENSE file for more info.
