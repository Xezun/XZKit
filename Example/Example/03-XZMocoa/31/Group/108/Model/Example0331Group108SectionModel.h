//
//  Example0331Group108SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

@import XZMocoaCore;
#import "Example0331Group108CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0331Group108SectionModel : NSObject <XZMocoaCollectionViewSectionModel>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, strong) Example0331Group108CellModel *model;
@end

NS_ASSUME_NONNULL_END
