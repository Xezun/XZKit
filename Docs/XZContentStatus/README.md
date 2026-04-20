# XZKit/ContentStatus

## 安装

```ruby
pod "XZKit/ContentStatus"
```

## 特性

- 仅支持 Swift 为 UIView 提供了描述其内容状态的入口。
- 实现方式为协议，开发者可根据需要来确认是否需要。

## 示例

只需要遵循协议即可，已提供了默认实现。

```
class SampleContentStatusView: UIView, ContentStatusRepresentable {
    
}
```

配置样式。

```
let view = SampleContentStatusView.init(frame: UIScreen.main.bounds)

view.setTitle("Content is empty now", forContentStatus: .empty)
view.setImage(UIImage(named: "ImageEmpty"), forContentStatus: .empty)

view.setTitle("Content is loading now", forContentStatus: .loading)
view.setImage(UIImage(named: "ImageLoading"), forContentStatus: .loading)
```

设置状态就会显示已设置的样式。

```
view.contentStatus = .empty

// 或者

view.contentStatus = .loading
```

状态 `.default` 表示默认状态，状态视图隐藏。
