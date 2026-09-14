//
//  XZMocoaModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/8/25.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaModule.h>
#else
#import "XZMocoaModule.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 数据模型遵循的协议。
///
/// 已为`NSObject`拓展`mocoaName`属性，因此任何`NSObject`子类只需声明遵循协议即可使用。
NS_SWIFT_UI_ACTOR @protocol XZMocoaModel
@optional
@property (nonatomic, copy, readonly, nullable) XZMocoaName mocoaName;
@end

@interface NSObject (XZMocoaModel)

@end

NS_ASSUME_NONNULL_END
