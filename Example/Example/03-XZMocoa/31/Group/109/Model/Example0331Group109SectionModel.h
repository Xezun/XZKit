//
//  Example0331Group109SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import <XZMocoa/XZMocoa.h>
#import "Example0331Group109CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0331Group109SectionModel : XZMocoaCollectionViewSectionModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, strong) Example0331Group109CellModel *model;
@end

NS_ASSUME_NONNULL_END
