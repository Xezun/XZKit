# XZML

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZML)
[![Version](https://img.shields.io/cocoapods/v/XZML.svg?style=flat)](https://cocoapods.org/pods/XZML)
[![License](https://img.shields.io/cocoapods/l/XZML.svg?style=flat)](https://cocoapods.org/pods/XZML)
[![Platform](https://img.shields.io/cocoapods/p/XZML.svg?style=flat)](https://cocoapods.org/pods/XZML)

## 示例项目 Example

要运行示例项目，需在拉取代码后，先在`Pods`目录执行`pod install`命令。

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## 版本需求 Requirements

iOS 12.0, Xcode 14.0

## 安装使用 Installation

推荐使用[CocoaPods](https://cocoapods.org)安装XZML组件。

XZML is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZML'
```

## 背景

XZML 是一款轻量级的富文本标记语言，可以解决在iOS开发中，富文本构造过程繁琐、以及不支持后端下发等问题。

## 示例

| XZML | 效果 | 说明 |
|:--|:--|:--|
| `日利率 <B&0.02%> <aaa#$0.08%>` | <span>日利率 <b>0.02%</b></span> <del><font color="gray">0.08%</font></del> | 设置`0.02%`粗体，`0.08%`灰色且带删除线 |

*因 GitHub 的 Markdown 不支持字体颜色，呈现效果可能并非实际效果*

## 语法

元素是构成XZML的基本单位，元素支持嵌套和样式继承，具体规则如下。

### 1、元素

#### 1.1 元素构成

元素由范围标记符、样式、文本内容三部分构成，形式如下。

> `范围起始标记` + `样式` + `文本内容` + `范围终止标记`

被`范围标记符`包裹的`文本内容`会应用指定的`样式`，其中：

- 起始标记：`<`

- 终止标记：`>`

- 样式：`样式值` + `样式标记符`

- 文本内容：纯文本字符，特殊字符需用`\`转义

#### 1.2 元素串联

`< 作用域1 >` `< 作用域2 >` `不属于作用域` `< 作用域3 >`

#### 1.3 元素嵌套

`< 作用域1` `< 作用域1.1` `< 作用域1.1.1 >` `>` `>`

#### 1.4 样式继承

`<` `样式1` `内容1` `<` `样式2` `内容2` `>` `内容3` `>`

`内容1`与`内容3`的样式相同，因为它们在同一对范围标记符内，`内容2`则会继承外层的`样式1`，`样式2`只对内层的`内容2`生效。

### 2、样式标记符

XZML 使用**固定格式**且简化的文本作为`样式值`，多属性样式值使用`@`符号分隔属性，基本格式如下。

`属性1` `@属性2` `@属性3` `样式标记符`

理论上，任何字符都可以作为样式标记符，但是使用不常用的**特殊符号**作为`样式标记符`，能减少转义符号的使用。以下符号在 XZML 中被用作`样式标记符`使用。

【样式标记符】

| 标记符 | 名称 | 属性1 | 属性2 | 属性3 | 示例 |
|----|--------|:------|:------|:--|--|
| #  | 文本颜色 | 前景色 | 背景色 |  | `<f00#红色文字>` |
| &  | 字体字号 | 字体 | 字号 | 基准线偏移  | `<宋体@20&宋体20号文字>` |
| $  | 文本修饰 | 样式 | 线型 | 颜色 | `<$带删除线的文字>` |
| *  | 安全模式 | 替代符号 | 重复次数 | | `<*安全模式变星星的文字>` |
| ~  | 超链接 | URL  | | | `<https://www.xezun.com/~打开Xezun官网>` |
| ^  | 文本段落 | `属性值` + `属性标记` | | | `<20H30M^最小行高20点，最大行高30点的段落>` |

【属性预设值】

在实际开发中，可使用预设值，降低 XZML 的复杂度。

```objc
[textLabel setAttributedTextWithXZMLString:@"文本甲 <&文本乙> <宋体&文本丙>" defaultAttributes:@{
    NSFontAttributeName: [UIFont fontWithName:@"Text-Font" size:14.0],
    XZMLFontAttributeName: [UIFont fontWithName:@"Number-Font" size:14.0],
}];
```

在上面这段代码中，`文本甲`将应用`Text-Font`字体，`文本乙`将应用`Number-Font`字体，`文本丙`将应用`宋体`字体。

| 样式   | 默认值                                 | 设置一个属性时               |
| ----- | ------------------------------------- | ---------------------------- |
| 字体   | XZMLFontAttributeName 指定字体，继承字号 | 作为字体名，与默认字号相同      |
| 颜色   | XZMLForegroundColorAttributeName      | 作为前景色，无背景色           |
| 删除线 | 单删除线                   | 作为删除线样式，与前景色相同     |
| 安全   | 4个星星                   | 作为星星的数量，与前景色相同     |

【简化字体名】

由于字体名字可能较长，而在业务中，大部分情况下，所使用的都是固定字体，因此可以通过设置字体缩写，来简化样式的书写，比如`<B&0.02%>`中`B`字体名，是通过如下方法提前注册的。

```objc
[XZMLParser setFontName:@"AmericanTypewriter-Bold" forAbbreviation:@"B"];
```

【颜色】

XZML使用十六进制颜色，基本与`css`规则一致。

| 格式     | 示例     | (r, g, b, a)                         | 效果                                                         |
| -------- | -------- | ------------------------------------ | ------------------------------------------------------------ |
| RGB      | D34      | (r: 0xDD, g: 0x33, b: 0x44, a: 0xFF) | <span style="display: inline-block; background-color: #d34; width: 20px; height: 20px;"> </span> |
| RGBA     | D34B     | (r: 0xDD, g: 0x33, b: 0x44, a: 0xBB) | <span style="display: inline-block; background-color: #d34b; width: 20px; height: 20px;"> </span> |
| RRGGBB   | 12BC89   | (r: 0x12, g: 0xBC, b: 0x89, a: 0xFF) | <span style="display: inline-block; background-color: #12bc89; width: 20px; height: 20px;"> </span> |
| RRGGBBAA | 12BC8955 | (r: 0x12, g: 0xBC, b: 0x89, a: 0x55) | <span style="display: inline-block; background-color: #12bc8955; width: 20px; height: 20px;"> </span> |

【转义字符】

转义字符`\`之后的第一个字符，作为原始字符使用；如果转义字符在末尾，则忽略该转义字符。

## Author

Xezun, developer@xezun.com

## License

XZML is available under the MIT license. See the LICENSE file for more info.
