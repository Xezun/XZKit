//
//  XZMocoaTableViewCellModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/27.
//

#import <Foundation/Foundation.h>
#if SWIFT_PACKAGE
#import "XZMocoaModel.h"
#else
#import "XZMocoaModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// UITableView 的 cell 的数据模型。
@protocol XZMocoaTableViewCellModel <XZMocoaModel>
@end

/// 因一致性而提供，非必须基类。
/// @note 任何遵循 XZMocoaTableViewCellModel 协议的对象都可以作为数据模型，而非必须基于此类。
@interface XZMocoaTableViewCellModel : NSObject <XZMocoaTableViewCellModel>
@end

NS_ASSUME_NONNULL_END
