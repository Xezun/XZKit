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
/// > 但是为避免被非 Mocoa 之外的功能使用，协议的实现并公开，需显式声明才可使用。
NS_SWIFT_UI_ACTOR @protocol XZMocoaModel <NSObject>

@optional
/// 在`Mocoa`中的名称。
@property (nonatomic, copy, readonly, nullable) XZMocoaName mocoaName;

@end

NS_ASSUME_NONNULL_END
