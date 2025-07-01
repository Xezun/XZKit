//
//  Example0330Group100SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

@import XZMocoaObjC;
#import "Example0330Group100CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0330Group100SectionModel : NSObject <XZMocoaTableViewSectionModel>
@property (nonatomic, strong) Example0330Group100CellModel *model;
@end

NS_ASSUME_NONNULL_END
