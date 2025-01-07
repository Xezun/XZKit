//
//  XZMocoaTableModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaListModel.h"

/// UITableView 的数据模型。
@protocol XZMocoaTableModel <XZMocoaListModel>
@end

#if !SWIFT_PACKAGE
/// 因一致性而提供，非必须基类。
/// @note 任何遵循 XZMocoaTableModel 协议的对象都可以作为数据模型，而非必须基于此类。
@interface XZMocoaTableModel : NSObject <XZMocoaTableModel>
@end
#endif
