//
//  XZMocoaObserver.h
//  XZMocoa
//
//  Created by 徐臻 on 2025/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaViewModel;

@interface XZMocoaObserver : NSObject
+ (XZMocoaObserver *)observerForModel:(NSObject *)model;
- (void)addViewModel:(XZMocoaViewModel *)viewModel forKeys:(NSArray<NSString *> *)keys;
- (void)removeViewModel:(XZMocoaViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
