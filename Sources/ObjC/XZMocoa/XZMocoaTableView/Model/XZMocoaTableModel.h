//
//  XZMocoaTableModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include("XZKit.h")
#import "XZMocoaGroupModel.h"
#else
#import <XZKit/XZMocoaGroupModel.h>
#endif

/// UITableView 的数据模型。
@protocol XZMocoaTableModel <XZMocoaGroupModel>
@end
