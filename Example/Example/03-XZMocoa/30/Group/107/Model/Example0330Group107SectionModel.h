//
//  Example0330Group107SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import <XZMocoa/XZMocoa.h>
#import "Example0330Group107CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0330Group107SectionModel : XZMocoaTableViewSectionModel
@property (nonatomic, strong) Example0330Group107CellModel *model;
@end

NS_ASSUME_NONNULL_END
