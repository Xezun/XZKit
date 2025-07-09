//
//  Example0330Group109SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

@import XZMocoa;
#import "Example0330Group109CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0330Group109SectionModel : NSObject <XZMocoaTableViewSectionModel>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, strong) Example0330Group109CellModel *model;
@end

NS_ASSUME_NONNULL_END
