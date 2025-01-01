//
//  Example0330Group110SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import <XZMocoa/XZMocoa.h>
#import "Example0330Group110CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0330Group110SectionModel : XZMocoaTableViewSectionModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, strong) Example0330Group110CellModel *model;
@end

NS_ASSUME_NONNULL_END
