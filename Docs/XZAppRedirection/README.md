# XZKit/AppRedirection

## 安装

```ruby
pod "XZKit/AppRedirection"
```

## 特性

只有在控制器处于显示状态时，才会收到重定向消息，以便跳转下一个控制器。

## 示例

1. 从任一控制器都可以发送重定向消息。比如从根控制器开始转发打开 https://www.baidu.com 的消息。

```swift
window!.rootViewController!.setNeedsRedirect(with: URL(string: "https://www.baidu.com"))
```

2. 重定向消息默认会沿着第一子控制器或模态控制器传播。控制器可以重写接收重定向消息的方法，自定义消息传播的下一级控制器。

```swift
override func didRecevieRedirection(_ redirection: Any) -> UIViewController? {
    guard let url = redirection as? URL else { return nil }
    let webVC = WebViewController(url: url)
    navigationController?.pushViewController(webVC, animated: true)
    return webVC
}
```