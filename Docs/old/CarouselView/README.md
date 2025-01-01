# XZKit/CarouselView

## 安装

```ruby
pod "XZKit/CarouselView"
```

## 效果

<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/CarouselView/1.gif" alt="XZKit.CarouselView" width="240"></img>
<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/CarouselView/2.gif" alt="XZKit.CarouselView" width="240"></img>
<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/CarouselView/3.gif" alt="XZKit.CarouselView" width="240"></img>

## 说明

*在 Swift 语言下，XZKit 库类名不需要前缀 XZ ，本文档代码示例使用 Swift 语言。*

视图 `XZCarouselView ` 为 `XZKit/CarouselView` 模块中的基础视图，提供了视图轮播的基础功能，主要是为了方便再此封装和继承，比如模块中的图片轮播图 `XZImageCarouselView` 组件、大图查看器 `XZImageViewer` 组件、多控制器轮播控制器 `XZCarouselViewController`  都是基于类 `XZCarouselView` 来实现的。

视图 `XZCarouselView ` 除了支持无限轮播、自动轮播、轮播方向、缩放等常用功能外，还支持内容自适应、获取轮播进度、自适应布局方向（针对阿拉伯语等自右向左布局等系统）、重用机制、添加自定义切换动画等功能。然而视图 `XZCarouselView ` 最大的特点不是这些，而是它的轮播进度可以即时的反馈给代理。虽然提供轮播进度并不是不困难的事情，但是却很少有第三方组件直接提供支持相关功能的接口。而轮播进度在做联动效果时很重要，精确的获取轮播进度，才能保证联动动画自然流畅。

举例来说，原生的 `UIPageViewController` 一般被用来做多控制器轮播（比如一般资讯 App 首页的多栏目结构），但是它很难获取轮播进度，因此用其做内容列表与菜单的联动，效果就很难做到完美，而实际情况也是如此，市场上很多资讯 App 的首页，都或多或少的存在这样的问题。比如目前已知的CSDN、IT之家、腾讯新闻等 App 首页，在列表页面连续切换时，栏目菜单没有正常滚动（或只有指示器动），点击栏目菜单，列表页面改变没有切换效果，显得不够自然。所以在控制器 `XZCarouselViewController` 的[示例代码](https://github.com/mlibai/XZKit/tree/master/Projects/Example/CarouselViewExample)中，以模仿IT之家 App 首页（上面的效果图3）为例，展示了如何通过 `XZCarouselViewController` 来实现列表与菜单的联动效果。

## 特性

水平/垂直轮播、无限轮播、自动轮播、缩放、内容适配方式、自适应布局方向、重用机制、自定义切换动画、转场进度、图片轮播图、全屏大图查看、轮播控制器、懒加载。

## 如何使用

### 1. XZCarouselView

轮播视图组件 `XZCarouselView ` 是 UIView 子类，像 UIView 一样使用即可。

```swift
let carouselView = CarouselView.init(frame: UIScreen.main.bounds);
self.addSubview(carouselView)
```

### 2. XZImageCarouselView

图片轮播图 `XZImageCarouselView` 继承自 `XZCarouselView` ，主要提供了直接使用 UIImage 数组或者图片 URL 数组作为数据源的功能，不用需要重复的去实现数据源代理协议。

```swift
let carouselView = ImageCarouselView.init(frame: UIScreen.main.bounds);
// 以图片链接作为数据源。
carouselView.imageURLs = self.imageURLs 
// 以 UIImage 对象作为数据源，轮播图此数据源图片。
carouselView.images = self.images
// 如果同时设置两种数据源，推荐使用下面的方法。
carouselView.setImages(self.images, imageURLs: self.imageURLs)
```

视图 `XZImageCarouselView` 不提供提供网络图片下载功能。一般情况下，图片下载、缓存统一管理比较合适，比如统一使用 `SDWebImage` ，因此要展示网络图片，还需实现 `XZImageCarouselViewDelegate` 协议。

```swift
func imageCarouselView(_ imageCarouselView: ImageCarouselView, imageView: UIImageView, loadImageFrom imageURL: URL, completion: @escaping (CGSize, Bool) -> Void) {
    // 设置展位图的大小。
    imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    // 使用 SDWebImage 加载图片。
    imageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "avatar"), completed: { (image, _, _, _) in
        if let image = image {
            completion(image.size, false) // 图片加载后，调用回调更新图片的实际大小。
        } else {
            imageView.image = UIImage(named: "error") // 加载错误图片。
            completion(CGSize(width: 120.0, height: 120.0), false)
        }
    })
}
```

### 3. XZImageViewer

图片大图查看器 `XZImageViewer` 在内部管理了一个 `XZCarouselView` ，用来展示图片，其自身主要是处理数据源及转场逻辑。

```swift
let viewer = ImageViewer.init()
viewer.delegate = self
// 设置 imageVier 默认显示的图片。
viewer.currentIndex = indexPath.item
// 最大缩放比
viewer.maximumZoomScale = 3.0
// 图片在 XZImageViewer 中的适配模式：保持宽高比自适应大小。
viewer.contentMode = .scaleAspectFit
// 关闭缩放锁。
viewer.isZoomingLockEnabled = false
// XZImageViewer 是控制器，像普通控制器一样 present 就可以了。
self.present(viewer, animated: true, completion: nil);
```

`XZImageViewer` 不负责加载图片，而是通过数据源代理来加载图片。

```swift
func imageViewer(_ imageViewer: ImageViewer, imageView: UIImageView, loadImageAt index: Int, completion: @escaping (CGSize, Bool) -> Void) {
    imageView.sd_setImage(with: imageURLs[index], completed: { (image, _, cacheType, _) in
        completion(image?.size ?? .zero, cacheType == .none)
    })
}
```

`XZImageViewer` 默认实现了一个“源视图-全屏”之间的转场特效，即微信朋友圈查看大图的类似效果，该特效需要实现代理协议 `XZImageViewerDelegate` 中的如下面两个方法。

```swift
// 这个方法用来告诉 XZImageViewer 源视图在屏幕上位置。
func imageViewer(_ imageViewer: ImageViewer, sourceRectForItemAt index: Int) -> CGRect {
    guard let cell = collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? Example2CollectionViewCell else { return .zero }
    return cell.convert(cell.bounds, to: self.view)
}							
// 这个方法用来告诉 XZImageViewer 图片在源视图上的适配方式。因为一般情况下，图片在源视图上展示的与大图查看模式展示的不一样，甚至并非同一张图片，
// 因此需要 XZImageViewer 改变它的适配方式，使其在与源视图相同大小时，展示的内容一样。
func imageViewer(_ imageViewer: ImageViewer, sourceContentModeForItemAt index: Int) -> UIView.ContentMode {
    return .scaleAspectFill
}
```

### 4. XZCarouselViewController

使用 `XZCarouselView` 实现的多控制器容器，用来替代 `UIPageViewController` 的最佳选择。借助于 `XZCarouselView` 特性，可以方便的处理控制器与菜单的动画效果，让切换效果看起来更自然。

```swift
// 菜单的点击事件。比如用 UICollectionView 实现的菜单，被点击时，只需要两行代码。
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true) // 滚动选中的菜单到中间
    carouselViewController.setCurrentIndex(indexPath.item, animated: true) // 设置当前页面
}
// 列表页面切换事件。
func carouselViewController(_ carouselViewController: CarouselViewController, didShow viewController: UIViewController, at index: Int) {
    self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true) // 滚动菜单到中间
}
// 过渡效果只需要在一个方法就行了。menuTranstion(to:transition:) 方法为根据当前 menuIndex、目标 newIndex、transition 来处理过渡效果的方法，具体参考示例代码。
func carouselViewController(_ carouselViewController: CarouselViewController, didTransition transition: CGFloat, animated: Bool) {
    let newIndex = carouselViewController.currentIndex
    if menuIndex == newIndex { // menuIndex 为菜单当前已选中的 index 
        if transition > 0 { // 滚往下一个。
            menuTranstion(to: menuIndex + 1, transition: transition)
        } else if transition < 0 {
            menuTranstion(to: menuIndex - 1, transition: -transition)
        } else { // 滚动取消
            menuTranstion(to: menuIndex, transition: 0)
            collectionView.reloadData() // 重置上面目标菜单的转场进度。
        }
    } else { // 页面已跳转到新的 index 。
        if (transition == 0) { // 完成跳转
            menuIndex = newIndex
            menuTranstion(to: menuIndex, transition: 0)
            collectionView.reloadData()
        } else { // 跳转中。
            menuTranstion(to: newIndex, transition: 1.0 - abs(transition))
        }
    }
}
```

`XZCarouselViewController` 已实现了更精确的机制，来控制子控制器的生命周期，可以更准确的把握子控制器的状态。因此与 UIPageViewController 不同，XZCarouselViewController 中的子控制器，只有在 XZCarouselViewController 处于显示状态时，才会触发 viewDidAppear 方法，即子控制器的 viewDidAppear 调用时，表示其确已完全显示在屏幕上（如果 XZCarouselViewController 触发 viewDidAppear 时在屏幕上）。

```swift
// 无示例代码。
```

一般来说，控制器重用的可能性比较小，但是并不是完全不需要，对于资讯类 App 来说尤其如此，因为大部分栏目共用的是同一个控制器类型。基于 `XZCarouselView` 的设计优势，使用 `XZCarouselViewController` 实现重用也变得很简单。

```swift
// 因为示例所用的子控制器都是同一类型，只有单一类型时，设置 isReusingModeEnabled 属性为 true 就可以实现重用。
// 这里为了模拟自定义重用机制，假定前 5 个栏目是专栏，使用的控制器类型互不相同，其它栏目使用相同类型的控制器。
func carouselViewController(_ carouselViewController: CarouselViewController, viewControllerFor index: Int, reusing reusingViewController: UIViewController?) -> UIViewController? {
    if index < 5 {
        if let viewController = indexedViewControllers[index] {
            return viewController
        }
        let webViewController = Example3ContentViewController.init(index: index) // 创建不可重用控制器
        webViewController.title = pages[index].title
        webViewController.load(url: pages[index].url)
        indexedViewControllers[index] = webViewController
        return webViewController
    }
    if reusableViewControllers.isEmpty {
        let webViewController = Example3ContentViewController.init(index: index) // 创建可重用控制器
        webViewController.title = pages[index].title
        webViewController.load(url: pages[index].url)
        return webViewController
    }
    let webViewController = reusableViewControllers.removeLast() // 复用可重用控制器
    webViewController.title = pages[index].title
    webViewController.load(url: pages[index].url)
    return webViewController
}
// XZCarouselViewController 询问已移除的控制器是否可以走内部的重用机制，返回 false 。
// 注意：内部重用机制，强引用的是控制器的视图，因此如果使用的话，需要对控制器强引用。
func carouselViewController(_ carouselViewController: CarouselViewController, shouldEnqueue viewController: UIViewController, at index: Int) -> Bool {
    guard index >= 5 else {
        return false
    }
    reusableViewControllers.append(viewController as! Example3ContentViewController) // 回收可重用控制器
    return false
}
```

## 实现机制

`XZCarouselView` 使用三图实现轮播，但是三图只是为了方便计算，一般情况下，轮播图上只有两图参与轮播（在 `keepsTransitioningViews` 属性为 `true` 时，因为要显示前后的图片，需要同时加载 4 张图片）。


## 其它示例

1. 内容适配模式。

`XZCarouselView` 使用 `contentMode` 属性来对内容视图进行适配，除 `UIViewContentModeRedraw` 外，其它模式的显示效果与 `UIImageView` 的 `contentModde` 属性的效果一样。
通过全局函数 `CGRect XZCarouselViewFittingContentWithMode(CGRect, CGSize, UIViewContentMode)` 可以获取视图在 `XZCarouselView` 中的布局。

- UIViewContentModeScaleToFill: 拉伸铺满整个显示区域。
- UIViewContentModeScaleAspectFill: 保持宽高比缩放至填充整个视图，视图可能会超出有效显示区域。
- UIViewContentModeCenter: 居中显示，视图可能会超出有效显示区域。
- UIViewContentModeScaleAspectFit: 保持宽高比缩放，使宽或高与有效区域的宽高相等且整个视图在有效区域内，然后居中显示。
- UIViewContentModeRedraw：该模式下，如果视图的宽高都不超过显示区域的宽高，那么视图按照 UIViewContentModeCenter 模式适配，否则按照 UIViewContentModeScaleAspectFit 模式适配。
- UIViewContentModeTop：按视图实际大小，与可视区域顶边对齐。
- UIViewContentModeBottom：按视图实际大小，与可视区域底边对齐。
- UIViewContentModeLeft：按视图实际大小，与可视区域左边对齐。
- UIViewContentModeRight：按视图实际大小，与可视区域右边对齐。
- UIViewContentModeTopLeft：按视图实际大小，与可视区域顶边和左边对齐。
- UIViewContentModeTopRight：按视图实际大小，与可视区域顶边和右边对齐。
- UIViewContentModeBottomLeft：按视图实际大小，与可视区域下边和左边对齐。
- UIViewContentModeBottomRight：按视图实际大小，与可视区域下边和右边对齐。

另外还支持拓展模式。

```Objective-C
/// XZCarouselView 额外支持的 UIViewContentMode 模式的计算方式：1000 * (fitMode + 1) + alignMode 。
/// @note 适配模式 fitMode 包括：ScaleToFill、ScaleAspectFill、ScaleAspectFit、Redraw 。
/// @note 对齐模式 alignMode 包括：Top、Left、Bottom、Right 。
UIKIT_EXTERN UIViewContentMode XZCarouselViewExtendingContentMode(UIViewContentMode fitMode, UIViewContentMode alignMode) NS_SWIFT_NAME(XZCarouselView.extending(_:at:));
```

2. 自定义转场动画。

在下面的例子中，展示了如何添加一个类似于原生的 Push/Pop 效果的切换动画。

```swift
let width: CGFloat = floor(UIScreen.main.bounds.width / 3.0)
let navigationAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform)); // 切换时的位置偏移。
navigationAnimation.values = [
    CATransform3DIdentity, CATransform3DMakeTranslation(+width, 0, 0),
    CATransform3DIdentity, CATransform3DIdentity,
    CATransform3DIdentity, CATransform3DIdentity,
    CATransform3DMakeTranslation(+width, 0, 0), CATransform3DIdentity
]
let shadowColorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowColor)) // 切换时的阴影效果。
shadowColorAnimation.fromValue = UIColor.black.cgColor
shadowColorAnimation.toValue   = UIColor.black.cgColor
let shadowRadiusAnimation = CAKeyframeAnimation.init(keyPath: #keyPath(CALayer.shadowRadius))
shadowRadiusAnimation.values = [5.0, 5.0, 5.0, 10.0, 10.0, 5.0, 5.0, 5.0]
let shadowOffsetAnimation = CABasicAnimation.init(keyPath: #keyPath(CALayer.shadowOffset))
shadowOffsetAnimation.fromValue = NSValue(cgSize: .zero);
shadowOffsetAnimation.toValue   = NSValue(cgSize: .zero);
let shadowOpacityAnimation = CAKeyframeAnimation.init(keyPath: #keyPath(CALayer.shadowOpacity))
shadowOpacityAnimation.values = [0.5, 0.5, 0.5, 0.0, 0.0, 0.5, 0.5, 0.5]

let transitionAnimation = CAAnimationGroup.init()
transitionAnimation.animations = [
    navigationAnimation,
    shadowColorAnimation, shadowRadiusAnimation, shadowOffsetAnimation, shadowOpacityAnimation
]
carouselView.transitionAnimation = transitionAnimation
carouselView.hierarchy = .navigation // 设置视图层次结构。
```

