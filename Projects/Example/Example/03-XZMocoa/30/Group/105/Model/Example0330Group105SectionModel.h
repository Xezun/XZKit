//
//  Example0330Group105SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

@import XZKit;
#import "Example0330Group105CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0330Group105SectionModel : NSObject <XZMocoaTableViewSectionModel>
@property (nonatomic, strong) Example0330Group105CellModel *model;
@end

NS_ASSUME_NONNULL_END
