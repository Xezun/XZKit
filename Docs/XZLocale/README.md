# XZLocale

## 安装

```ruby
pod "XZLocale"
```

## 效果

<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/AppLanguage/1.gif" alt="XZKit.AppLanguage" width="240"></img>

## 实现原理

在运行时动态修改了 `NSBundle.mainBundle` 的类型，使得语言在切换后，可以立即生效（新的页面）。

## 示例

ObjectiveC 示例：
```ObjectiveC
XZLocalization.preferredLanguage = XZLanguageEnglish;
```

Swift 示例：
```Swift
// 设置当前语言。
XZLocalization.preferredLanguage = .English
// XZKit 优化的语言国际化函数。
textLabel.text = XZLocalizedString("我的名字叫{0}。", names[indexPath.row], comment: "My Name is {0}.")
```
