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
/// 使用 `NS_REFINED_FOR_SWIFT` 的原因是，定义了实例属性后，无法使用静态属性，所以在 Swift 中，所有标识符全部重新定义。
/// ```swift
/// // 假如有此拓展
/// extension XZMocoaKey {
///     var name: XZMocoaKey {
///         return "name"
///     }
/// }
///
/// // 那么就无法使用 name 了
/// let key = XZMocoaKey.name // 编译报错。
/// ```
///
/// 当前文件中的标识符是通用的，分类只表明标识符的初始来源，并不表示限制其应用范围。
typedef NSString *XZMocoaKey NS_EXTENSIBLE_STRING_ENUM;

/// 匿名事件，值为空字符串。如果视图模型只有一个事件，或者没必要细分事件时，可以使用此名称。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyNone NS_SWIFT_NAME(None);

// MARK: - 通用

FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDefault        NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyContentStatus  NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStatus         NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsChecked      NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsEnabled      NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsEmpty        NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyValue          NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyName           NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyType           NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyList           NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIcon           NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyColor          NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeySubtitle       NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDetailText     NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStartAnimating NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStopAnimating  NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsRefreshing   NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsRequesting   NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsLoading      NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDate           NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTime           NS_REFINED_FOR_SWIFT;

// MARK: - UIView

@class UIView;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsHidden        NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAlpha           NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFrame           NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyBounds          NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyCenter          NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTransform       NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTintColor       NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyBackgroundColor NS_REFINED_FOR_SWIFT;

// MARK: - UILabel

@class UILabel;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyText                 NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFont                 NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTextColor            NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyShadowColor          NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAttributedText       NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyHighlightedTextColor NS_REFINED_FOR_SWIFT;

// MARK: - UILabel

@class UITextField;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyPlaceholder NS_REFINED_FOR_SWIFT;

// MARK: - UIImageView

@class UIImageView;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyImage            NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyHighlightedImage NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsAnimating      NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyURL              NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyImageURL         NS_REFINED_FOR_SWIFT;

// MARK: - UIButton

@class UIButton;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTitle           NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAttributedTitle NS_REFINED_FOR_SWIFT;

// MARK: - UISwitch

@class UISwitch;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsOn           NS_REFINED_FOR_SWIFT;

// MARK: - UINavigationBar

@class UINavigationBar;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsTranslucent      NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyPrefersLargeTitles NS_REFINED_FOR_SWIFT;

// MARK: - 动作

/// 重载事件。适用情形：通知上级，执行重载模块的操作（数据已经更新）。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyReload NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyReloadData NS_REFINED_FOR_SWIFT;
/// 更新操作。适用情形：通知上级，执行数据编辑的操作（数据还未编辑）。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyModify NS_REFINED_FOR_SWIFT;
/// 插入操作。适用情形：通知上级，执行数据插入的操作（新数据未插入）。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyInsert NS_REFINED_FOR_SWIFT;
/// 删除操作。适用情形：通知上级，执行删除数据的操作（数据还未删除）。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDelete NS_REFINED_FOR_SWIFT;
/// 选择操作。比如单选 cell 时，只能由上层控制单选。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeySelect NS_REFINED_FOR_SWIFT;
/// 反选操作。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDeselect             NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyConfirm              NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeySubmit               NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyCancel               NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyClick                NS_REFINED_FOR_SWIFT;
/// 起始时间选择操作。比如时间区间选择器的开始时间。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFrom                 NS_REFINED_FOR_SWIFT;
/// 结束时间选择操作。比如时间区间选择器的结束时间。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTo                   NS_REFINED_FOR_SWIFT;

// MARK: - 事件

FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyValueDidChange       NS_REFINED_FOR_SWIFT;
/// 内容发生改变时，通知上层模块。
///
/// 当 Mocoa 接管 NSFetchedResultsController 事件之后，列表发生更新后，会向上层模块发送此事件。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyContentDidChange     NS_REFINED_FOR_SWIFT;
/// 导航左侧区事件。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyNavigationBackAction NS_REFINED_FOR_SWIFT;
/// 导航右侧区事件。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyNavigationMoreAction NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewWillAppear       NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewDidAppear        NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewWillDisappear    NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewDidDisappear     NS_REFINED_FOR_SWIFT;
/// 列表头部开始刷新。
///
/// 当使用 XZRefresh 组件时，发生刷新事件后，将通过事件通道，把刷新视图 refreshView 以此事件名，传递给 viewModel 对象。
/// - events.source 为 XZMocoaGroupView 子类对象。
/// - events.value 为 refreshView 对象。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyHeaderDidBeginRefreshing NS_REFINED_FOR_SWIFT;
/// 列表尾部开始刷新。
///
/// 当使用 XZRefresh 组件时，发生刷新事件后，将通过事件通道，把刷新视图 refreshView 以此事件名，传递给 viewModel 对象。
/// - events.source 为 XZMocoaGroupView 子类对象。
/// - events.value 为 refreshView 对象。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFooterDidBeginRefreshing NS_REFINED_FOR_SWIFT;

// MARK: - 参数

/// 传递给目标页面的数据模型。
///
/// 比如在商品列表页，点击商品打开详情页时，可以将商品的数据模型传递给目标页面。
///
/// 在使用 Mocoa URL 打开目标页面时，如果目标页面注册了 `viewModelClass` 类型，
/// 那么 Mocoa 会自动通过此 key 对应的 `model` 为目标页面创建视图模型。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyModel      NS_REFINED_FOR_SWIFT;
/// 传递给目标页面参数中 identifier 字段。
///
/// 通过标识符向页面传值当通用字段。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIdentifier NS_REFINED_FOR_SWIFT;
/// 在 XZMocoaOptions 中，通过此键名指定目标模块的视图模型对象，或打开目标模块的源模块。
///
/// 如果此键名指定的对象，是目标模块的视图模型类型，那么该对象将直接作为目标模块的视图模型使用。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyViewModel  NS_REFINED_FOR_SWIFT;

NS_ASSUME_NONNULL_END
