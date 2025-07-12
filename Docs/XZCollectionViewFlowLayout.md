# XZCollectionViewFlowLayout

[![Version](https://img.shields.io/cocoapods/v/XZCollectionViewFlowLayout.svg?style=flat)](https://cocoapods.org/pods/XZCollectionViewFlowLayout)
[![License](https://img.shields.io/cocoapods/l/XZCollectionViewFlowLayout.svg?style=flat)](https://cocoapods.org/pods/XZCollectionViewFlowLayout)
[![Platform](https://img.shields.io/cocoapods/p/XZCollectionViewFlowLayout.svg?style=flat)](https://cocoapods.org/pods/XZCollectionViewFlowLayout)

A collection view layout that gives you control over the horizontal and vertical alignment of the cells. You can use it to align the cells like words in a left- or right-aligned text and you can specify how the cells are vertically aligned within their rows.

Other than that, the layout behaves exactly like Apple's [`UICollectionViewFlowLayout`](https://developer.apple.com/reference/uikit/uicollectionviewflowlayout).

## 示例工程 Example

要运行示例工程，请在拉取代码后，先在 `Pods` 目录下执行 `pod install` 命令。

To run the example project, clone the repo, and run `pod install` from the `Pods` directory first.

## 环境需求 Requirements

iOS 12.0, Xcode 14.0

## 如何安装 Installation

推荐使用 [CocoaPods](https://cocoapods.org) 安装 `XZCollectionViewFlowLayout` 组件。

`XZCollectionViewFlowLayout` is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZCollectionViewFlowLayout'
```

## 对齐方式 Available Alignment Options

You can use _any_ combination of horizontal and vertical alignment to achieve your desired layout.

```swift
open var lineAlignment: XZCollectionViewFlowLayout.LineAlignment
open var interitemAlignment: XZCollectionViewFlowLayout.InteritemAlignment
```

### Horizontal Alignment:

* `lineAlignment = .leading`

![Example layout for lineAlignment = .leading](Images/line-alignment-leading.png)

* `lineAlignment = .center`

![Example layout for lineAlignment = .center](Images/line-alignment-center.png)

* `lineAlignment = .trailing`

![Example layout for lineAlignment = .trailing](Images/line-alignment-trailing.png)

* `lineAlignment = .justified`

![Example layout for lineAlignment = .justified](Images/line-alignment-justified.png)

* `lineAlignment = .justifiedLeading`

![Example layout for lineAlignment = .justifiedLeading](Images/line-alignment-justifiedLeading.png)
  
* `lineAlignment = .justifiedCenter`

![Example layout for lineAlignment = .justifiedCenter](Images/line-alignment-justifiedCenter.png)
 
* `lineAlignment = .justifiedTrailing`

![Example layout for lineAlignment = .justifiedTrailing](Images/line-alignment-justifiedTrailing.png)

### Vertical Alignment:

* `interitemAlignment = .ascended`

![Example layout for interitemAlignment = .ascended](Images/interitem-alignment-ascended.png)

* `interitemAlignment = .median`

![Example layout for interitemAlignment = .median](Images/interitem-alignment-median.png)

* `interitemAlignment = .descended`

![Example layout for interitemAlignment = .descended](Images/interitem-alignment-descended.png)

## Usage

### Setup in Interface Builder

1. You have a collection view in Interface Builder and setup its data source appropriately. Run the app and make sure everything works as expected (except the cell alignment).

2. In the Document Outline, select the collection view layout object.

3. In the Identity Inspector, set the layout object's custom class to `XZCollectionViewFlowLayout`.

    ![Screenshot: How to set a custom class for the layout object in Interface Builder](Images/usage-custom-layout-class.png)

4. Add and customize the following code to your view controller's `viewDidLoad()` method:

    ```Swift
    let layout = collectionView.collectionViewLayout as! XZCollectionViewFlowLayout
    layout.lineAlignment = .leading
    layout.interitemAlignment = .ascended
    ```
        
> If you omit any of the last two lines the default alignment will be used (horizontally justified, vertically median).

### Setup in code

1. Create a new `XZCollectionViewFlowLayout` object and specify the alignment you want:

    ```Swift
    let layout = XZCollectionViewFlowLayout(lineAlignment: .leading, interitemAlignment: .ascended)
    ```

2. Either create a new collection view object and and initialize it with `XZCollectionViewFlowLayout`:

    ```Swift
    let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
    ```

    **or** assign `XZCollectionViewFlowLayout` to the `collectionViewLayout` property of an existing collection view:

    ```Swift
    collectionView.collectionViewLayout = layout
    ```

3. Implement your collection view's data source.

4. Run the app.

---

### Additional configuration

还可以通过 `XZCollectionViewDelegateFlowLayout` 协议，自定义 `line` 或 `column` 的对齐方式。

    ```Swift
    func collectionView(_ collectionView: UICollectionView, layout: XZCollectionViewFlowLayout, lineAlignmentForLineAt indexPath: IndexPath) -> XZCollectionViewFlowLayout.LineAlignment {
        return indexPath.line % 2 == 0 ? .leading : .trailing
    }

    func collectionView(_ collectionView: UICollectionView, layout: XZCollectionViewFlowLayout, interitemAlignmentForItemAt indexPath: IndexPath) -> XZCollectionViewFlowLayout.InteritemAlignment {
        return indexPath.column % 2 == 0 ? .ascended : .descended
    }
    ```

在 `XZCollectionViewDelegateFlowLayout` 协议的代理方法中，可以通过参数 `indexPath` 直接访问到 `line` 或 `column` 信息。 此外，通过 `layout` 参数，还可以获取 `line` 和 `column` 的数量。

    ```swift
    let lines = layout.numberOfLines(inSection: indexPath.section)
    let columns = layout.numberOfColumns(inLine: indexPath.line, inSection: indexPath.section)
    ```

> 仅在 `XZCollectionViewDelegateFlowLayout` 协议的方法中的参数 `indexPath` 可获取 `line` 或 `column` 信息。
> 在 OC 环境下，需要使用前缀，即 `xz_line` 或 `xz_column` 属性。

---


## Author

Xezun, developer@xezun.com

## License

XZCollectionViewFlowLayout is available under the MIT license. See the LICENSE file for more info.
