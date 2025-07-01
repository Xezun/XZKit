//
//  Example0322ViewModel.h
//  Example
//
//  Created by Xezun on 2023/8/9.
//

@import XZMocoaObjC;

NS_ASSUME_NONNULL_BEGIN

@interface Example0322ViewModel : XZMocoaViewModel

@property (nonatomic, strong, readonly) XZMocoaCollectionViewModel *collectionViewModel;
@property (nonatomic, copy, readonly) NSArray<NSString *> *testActions;
- (void)performTestActionAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
