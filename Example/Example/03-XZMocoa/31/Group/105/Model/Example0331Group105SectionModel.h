//
//  Example0331Group105SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import <XZMocoa/XZMocoa.h>
#import "Example0331Group105CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0331Group105SectionModel : XZMocoaCollectionViewSectionModel
@property (nonatomic, strong) Example0331Group105CellModel *model;
@end

NS_ASSUME_NONNULL_END
