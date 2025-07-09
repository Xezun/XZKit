//
//  Example0331Group101SectionModel.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//
// 模拟 cell 模块 ViewModel 没有注册的情况

@import XZKit;
#import "Example0331Group101CellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0331Group101SectionModel : NSObject <XZMocoaCollectionViewSectionModel>
@property (nonatomic, strong) Example0331Group101CellModel *model;
@end

NS_ASSUME_NONNULL_END
