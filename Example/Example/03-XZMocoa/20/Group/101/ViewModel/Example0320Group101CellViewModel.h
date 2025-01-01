//
//  Example0320Group101CellViewModel.h
//  Example
//
//  Created by Xezun on 2023/7/24.
//

#import <XZMocoa/XZMocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Example0320Group101CellViewModel : XZMocoaTableViewCellViewModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, copy) NSArray<NSURL *> *images;

@end

NS_ASSUME_NONNULL_END
