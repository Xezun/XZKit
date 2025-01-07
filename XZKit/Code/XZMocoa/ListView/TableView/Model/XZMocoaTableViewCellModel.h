//
//  XZMocoaTableViewCellModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/27.
//

#import <Foundation/Foundation.h>
#import "XZMocoaModel.h"

NS_ASSUME_NONNULL_BEGIN

/// UITableView 的 cell 的数据模型。
@protocol XZMocoaTableViewCellModel <XZMocoaModel>
@end

#if !SWIFT_PACKAGE
/// 因一致性而提供，非必须基类。
/// @note 任何遵循 XZMocoaTableViewCellModel 协议的对象都可以作为数据模型，而非必须基于此类。
@interface XZMocoaTableViewCellModel : NSObject <XZMocoaTableViewCellModel>
@end
#endif

NS_ASSUME_NONNULL_END
