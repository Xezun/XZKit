//
//  Example0320Group102CellViewModel.h
//  Example
//
//  Created by Xezun on 2023/7/27.
//

@import XZMocoaCore;

NS_ASSUME_NONNULL_BEGIN

@interface Example0320Group102CellViewModel : XZMocoaTableViewCellViewModel

@property (nonatomic, copy) NSArray<NSURL *> *images;

@property (nonatomic) NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
