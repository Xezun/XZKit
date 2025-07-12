//
//  Example0322TextCell.h
//  Example
//
//  Created by Xezun on 2023/8/9.
//

@import XZKit;
#import "Example0322TextViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0322TextCell : UICollectionViewCell <XZMocoaCollectionViewCell>
@property (nonatomic, strong, nullable) Example0322TextViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;
@end

NS_ASSUME_NONNULL_END
