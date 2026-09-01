//
//  XZMocoaModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/8/25.
//

#import "XZMocoaModule.h"

NS_ASSUME_NONNULL_BEGIN

/// 数据模型遵循的协议。
/// > 已在内部为`NSObject`实现此协议，因此，任何 NSObject 子类都可以作为数据模型。
/// > 但是为避免被非 Mocoa 之外的功能使用，协议的实现未公开，需显式声明才可使用。
NS_SWIFT_UI_ACTOR @protocol XZMocoaModel <NSObject>

@optional
/// 在`Mocoa`中的名称。
@property (nonatomic, copy, readonly, nullable) XZMocoaName mocoaName;

/// 用于差异分析的稳定标识。
///
/// 标识在同一个 XZMocoaKind 范围内（跨所有 section）必须唯一，不同 kind 之间互不影响，允许使用相同字符串。
/// 若同一 kind 内出现重复标识，批量更新将放弃差异分析，退化为全量刷新。
///
/// 未实现或返回空字符串时，以模型对象自身作为标识，且业务应保证该模型唯一。
@property (nonatomic, copy, readonly, nullable) NSString *mocoaIdentifier;

@end

@class XZMocoaViewModel;

@interface NSObject (XZMocoaModel)
@end

NS_ASSUME_NONNULL_END
