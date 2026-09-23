//
//  XZMocoaDefines.h
//  XZMocoa
//
//  Created by Xezun on 2021/11/5.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMacros.h>
#import <XZKit/XZMocoaKey.h>
#else
#import "XZMacros.h"
#import "XZMocoaKey.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 合法的视图最小宽度或最小高度，实际值为 0.000001 千万分之一。
/// @note
/// 在 iOS 14.x 系统中，设置 UITableView 中 Section 的 Header/Footer 高度为 `CGFLOAT_MIN` 能正常显示，但是在调用如下方法时，会触发 NaN 崩溃。
/// @code
/// [tableView reloadSections:indexes withRowAnimation:(UITableViewRowAnimationTop)]
/// @endcode
UIKIT_EXTERN CGFloat const XZMocoaMinimumViewDimension NS_SWIFT_NAME(viewMinimumDimension);

/// 合法的最小视图大小。
/// @discussion
/// 在某些情形中，直接设置大小为 0 会显示不正常。比如在 UICollectionView 中，Cell 的宽度或高度为 0 或 `CGFLOAT_MIN` 值，会造成普通的 cell 不能正常展示。
UIKIT_EXTERN CGSize  const XZMocoaMinimumViewSize NS_SWIFT_NAME(viewMinimumSize);

/// 模块的名称，区分同层级不同模块的名称。
///
/// 关于模块名称的特殊值：
/// - `nil` 因为没有设置而没有名称。
/// - `kMocoaNilName` 没有名称，或名称为空，或默认名称，或者以空为名称，或没有设置名称时的名称。
/// - 非空字符串，具体名称。
///
/// #### 注意事项
/// - 字符 `:`、`/` 为保留字符，在 ``XZMocoaName`` 中使用，可能会产生不可预料的结果。
/// - 合法的 ``XZMocoaName`` 字符仅包括 `0-9`、`A-Z`、`a-z`、`-`、`.` 等字符。
/// - 在 tableView/collectionView 中，具名的 cell 子模块若没设置，则会将以 kMocoaNilName 为名称的子模块，作为默认模块加载。
typedef NSString *XZMocoaName NS_TYPED_EXTENSIBLE_ENUM;

/// 模块的分类，区分同层级不同模块的类型。
///
/// 关于模块分类的特殊值：
/// - `nil` 因为没有设置而没有分类。
/// - `kMocoaNilKind` 没有分类，或分类为空，或默认分类，或者以空为分类，或没有设置分类时的名称。
/// - 非空字符串，具体分类。
///
/// #### 注意事项
/// - 字符 `:`、`/` 为保留字符，在 ``XZMocoaKind`` 中使用，可能会产生不可预料的结果。
/// - 合法的 ``XZMocoaKind`` 字符仅包括 `0-9`、`A-Z`、`a-z`、`-`、`.` 等字符。
/// - 在 tableView/collectionView 中，所有 cell 子模块都属于 `kMocoaNilKind` 默认分类。
typedef NSString *XZMocoaKind NS_TYPED_EXTENSIBLE_ENUM;

/// `XZMocoaName` 中的 `nil` 值，实际值为空字符串。
///
/// 与其它 Name 命名风格不一致，避免占位命名，且在 Swift 中使用名称不变。
FOUNDATION_EXPORT XZMocoaName const kMocoaNilName NS_REFINED_FOR_SWIFT NS_SWIFT_NAME(__kMocoaNilName);
/// 主要子模块名。
FOUNDATION_EXPORT XZMocoaName const XZMocoaNameMain;
/// 首页子模块名。
FOUNDATION_EXPORT XZMocoaName const XZMocoaNameHome;
/// 用户子模块名。
FOUNDATION_EXPORT XZMocoaName const XZMocoaNameUser;
/// 列表子模块名
FOUNDATION_EXPORT XZMocoaName const XZMocoaNameList;
/// 占位视图的名称。
FOUNDATION_EXPORT XZMocoaName const XZMocoaNamePlaceholder;

/// `XZMocoaKind` 中的 `nil` 值，实际值为空字符串。
///
/// 与其它 Kind 命名风格不一致，避免占位命名，且在 Swift 中使用名称不变。
FOUNDATION_EXPORT XZMocoaKind const kMocoaNilKind NS_REFINED_FOR_SWIFT NS_SWIFT_NAME(__kMocoaNilKind);
/// 用于表示 Header 的分类。
FOUNDATION_EXPORT XZMocoaKind const XZMocoaKindHeader;
/// 用于表示 Footer 的分类。
FOUNDATION_EXPORT XZMocoaKind const XZMocoaKindFooter;

/// 构造重用标识符。
/// - Parameters:
///   - kind: 要构造标识符对象的分类
///   - name: 要构造标识符对象的名字
FOUNDATION_STATIC_INLINE NSString *XZMocoaReuseIdentifier(XZMocoaKind _Nullable kind, XZMocoaName _Nullable name) {
    return [NSString stringWithFormat:@"%@:%@", (kind ?: kMocoaNilKind), (name ?: kMocoaNilName)];
}

NS_ASSUME_NONNULL_END
