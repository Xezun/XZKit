//
//  Example0330Group106SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import <XZMocoa/XZMocoa.h>
#import "Example0330Group106CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0330Group106SectionModel : XZMocoaTableViewSectionModel
@property (nonatomic, strong) Example0330Group106CellModel *model;
@end

NS_ASSUME_NONNULL_END
