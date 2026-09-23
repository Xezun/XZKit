//
//  XZMocoaKey.h
//  XZKit
//
//  Created by 徐臻 on 2026/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 标识符，区分 Key Events 和 Key Target Action 事件的标识符。
///
///
/// 关于 `XZMocoaKey` 特殊值的解释：
/// - `nil` 因为没有设置而没有键。
/// - `kMocoaNilKey` 没有键，或键为空，或以空为键。
/// - 非空字符串，具体键。
///
/// 当前文件中的标识符是通用的，分类只表明标识符的初始来源，并不表示限制其应用范围。
///
/// 纯 Swift 类型可以使用 `@dynamicMemberLookup` 注解，让类型支持点任意键的语法，后续可以考虑。
///
/// 桥接到 Swift 中的 XZMocoaKey 类型，如果定义了同名的实例属性，会导致在 Objc 中定义的静态属性无法使用。
/// ```swift
/// // 假如有此拓展，定义实例属性，目的是想实现通过链式点语法表示 keyPath 比如 .list.name
/// extension XZMocoaKey {
///     var name: XZMocoaKey { return "name" }
/// }
/// // 应该是编译器问题，上面的做法会导致，桥接到 Swift 中的 name 静态属性无法使用。
/// let key = XZMocoaKey.name // 编译报错：Instance member 'name' cannot be used on type 'XZMocoaKey'
/// ```
typedef NSString *XZMocoaKey NS_TYPED_EXTENSIBLE_ENUM;

/// `XZMocoaKey` 中的 `nil` 值，实际值为空字符串。
///
/// 与其它 Key 命名风格不一致，避免占位命名，且在 Swift 中使用名称不变。
FOUNDATION_EXPORT XZMocoaKey const kMocoaNilKey NS_REFINED_FOR_SWIFT NS_SWIFT_NAME(__kMocoaNilKey);

// MARK: - 通用

FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDefault;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyContentStatus;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStatus;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsChecked;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsEnabled;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsEmpty;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyValue;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyName;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyType;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyList;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIcon;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyColor;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeySubtitle;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDetailText;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStartAnimating;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStopAnimating;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsRefreshing;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsRequesting;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsLoading;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDate;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTime;

// MARK: - UIView

@class UIView;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsHidden;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAlpha;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFrame;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyBounds;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyCenter;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTransform;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTintColor;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyBackgroundColor;

// MARK: - UILabel

@class UILabel;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyText;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFont;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTextColor;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyShadowColor;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAttributedText;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyHighlightedTextColor;

// MARK: - UITextField

@class UITextField;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyPlaceholder;

// MARK: - UIImageView

@class UIImageView;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyImage;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyHighlightedImage;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsAnimating;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyURL;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyImageURL;

// MARK: - UIButton

@class UIButton;

/// 标题键。
///
/// 如果初始化控制器的 `options` 参数中，且控制器 `title` 属性未被赋值，那么此键的值将成为控制器的标题。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTitle;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAttributedTitle;

// MARK: - UISwitch

@class UISwitch;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsOn;

// MARK: - UINavigationBar

@class UINavigationBar;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsTranslucent;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyPrefersLargeTitles;

// MARK: - 动作

/// 重载事件。适用情形：通知上级，执行重载模块的操作（数据已经更新）。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyReload;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyReloadData;
/// 更新操作。适用情形：通知上级，执行数据编辑的操作（数据还未编辑）。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyModify;
/// 插入操作。适用情形：通知上级，执行数据插入的操作（新数据未插入）。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyInsert;
/// 删除操作。适用情形：通知上级，执行删除数据的操作（数据还未删除）。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDelete;
/// 选择操作。比如单选 cell 时，只能由上层控制单选。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeySelect;
/// 反选操作。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDeselect;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyConfirm;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeySubmit;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyCancel;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyClick;
/// 起始时间选择操作。比如时间区间选择器的开始时间。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFrom;
/// 结束时间选择操作。比如时间区间选择器的结束时间。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTo;

// MARK: - 事件

FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyValueDidChange;
/// 内容发生改变时，通知上层模块。
///
/// 当 Mocoa 接管 NSFetchedResultsController 事件之后，列表发生更新后，会向上层模块发送此事件。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyContentDidChange;
/// 导航左侧区事件。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyNavigationBackAction;
/// 导航右侧区事件。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyNavigationMoreAction;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewWillAppear;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewDidAppear;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewWillDisappear;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewDidDisappear;
/// 列表头部开始刷新。
///
/// 当使用 XZRefresh 组件时，发生刷新事件后，将通过事件通道，把刷新视图 refreshView 以此事件名，传递给 viewModel 对象。
/// - events.source 为 XZMocoaGroupView 子类对象。
/// - events.value 为 refreshView 对象。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyHeaderDidBeginRefreshing;
/// 列表尾部开始刷新。
///
/// 当使用 XZRefresh 组件时，发生刷新事件后，将通过事件通道，把刷新视图 refreshView 以此事件名，传递给 viewModel 对象。
/// - events.source 为 XZMocoaGroupView 子类对象。
/// - events.value 为 refreshView 对象。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFooterDidBeginRefreshing;

// MARK: - 参数

/// 传递给目标页面的数据模型。
///
/// 比如在商品列表页，点击商品打开详情页时，可以将商品的数据模型传递给目标页面。
///
/// 在使用 Mocoa URL 打开目标页面时，如果目标页面注册了 `viewModelClass` 类型，
/// 那么 Mocoa 会自动通过此 key 对应的 `model` 为目标页面创建视图模型。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyModel;
/// 传递给目标页面参数中 identifier 字段。
///
/// 通过标识符向页面传值的通用字段。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIdentifier;
/// 在 XZMocoaOptions 中，通过此键名指定目标模块的视图模型对象，或打开目标模块的源模块。
///
/// 如果此键名指定的对象，是目标模块的视图模型类型，那么该对象将直接作为目标模块的视图模型使用。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewModel;

NS_ASSUME_NONNULL_END
