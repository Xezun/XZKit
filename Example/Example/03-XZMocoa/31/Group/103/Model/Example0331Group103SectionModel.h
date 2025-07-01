//
//  Example0331Group103SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

@import XZMocoaObjC;
#import "Example0331Group103CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0331Group103SectionModel : NSObject <XZMocoaCollectionViewSectionModel>
@property (nonatomic, strong) Example0331Group103CellModel *model;
@end

NS_ASSUME_NONNULL_END
