//
//  Example0322TextViewModel.h
//  Example
//
//  Created by Xezun on 2023/8/9.
//

#import <XZMocoa/XZMocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Example0322TextViewModel : XZMocoaCollectionViewCellViewModel
@property (nonatomic, copy, readonly) NSString *name  XZ_MOCOA_KEY(name);
@property (nonatomic, copy, readonly) NSString *phone XZ_MOCOA_KEY(phone);
@end

NS_ASSUME_NONNULL_END
