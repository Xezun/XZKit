//
//  XZMocoaModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/8/25.
//

#import "XZMocoaModule.h"

NS_ASSUME_NONNULL_BEGIN

/// 数据模型遵循的协议。
/// @note 已在内部为`NSObject`实现此协议，任何对象 NSObject 子类都可以作为数据模型。
/// @note 为避免 Mocoa 功能被非 Mocoa 模块意外引用，协议的实现并公开，需显式声明才可使用。
NS_SWIFT_UI_ACTOR @protocol XZMocoaModel <NSObject>

@optional
/// 在`Mocoa`中的名称。
@property (nonatomic, copy, nullable) XZMocoaName mocoaName;

@end

#if !SWIFT_PACKAGE
/// 因一致性而提供，非必须基类。
/// @note 任何遵循 XZMocoaModel 协议的对象都可以作为数据模型，而非必须基于此类。
@interface XZMocoaModel : NSObject <XZMocoaModel>
@end
#endif

NS_ASSUME_NONNULL_END
