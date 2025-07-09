//
//  Example0330Group108SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

@import XZMocoa;
#import "Example0330Group108CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0330Group108SectionModel : NSObject <XZMocoaTableViewSectionModel>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, strong) Example0330Group108CellModel *model;
@end

NS_ASSUME_NONNULL_END
