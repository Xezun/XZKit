//
//  XZMocoaDefines.h
//  XZMocoa
//
//  Created by Xezun on 2021/11/5.
//

#import <UIKit/UIKit.h>
#import "XZMacros.h"
#import "XZMocoaKey.h"

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

/// 模块的名称。
/// @attention 字符`:`、`/`为保留字符，不可在 XZMocoaName 中使用。
typedef NSString *XZMocoaName NS_EXTENSIBLE_STRING_ENUM;

/// 模块的分类。
/// @attention 字符`:`、`/`为保留字符，不可在 XZMocoaKind 中使用。
typedef NSString *XZMocoaKind NS_EXTENSIBLE_STRING_ENUM;

/// 默认名称，或者没有名称。
/// @discussion
/// 在 tableView/collectionView 中，具名的 section 在查询 cell 子模块时，会查询 XZMocoaNameDefault 的 section 模块。
FOUNDATION_EXPORT XZMocoaName const XZMocoaNameDefault;
/// 默认分类，或者没有分类。
FOUNDATION_EXPORT XZMocoaKind const XZMocoaKindDefault;
/// 用于表示 Header 的分类。
FOUNDATION_EXPORT XZMocoaKind const XZMocoaKindHeader;
/// 用于表示 Footer 的分类。
FOUNDATION_EXPORT XZMocoaKind const XZMocoaKindFooter;

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

/// 构造重用标识符。
/// - Parameters:
///   - kind: 要构造标识符对象的分类
///   - name: 要构造标识符对象的名字
FOUNDATION_STATIC_INLINE NSString *XZMocoaReuseIdentifier(XZMocoaKind _Nullable kind, XZMocoaName _Nullable name) {
    return [NSString stringWithFormat:@"%@:%@", (kind ?: XZMocoaKindDefault), (name ?: XZMocoaNameDefault)];
}

NS_ASSUME_NONNULL_END
