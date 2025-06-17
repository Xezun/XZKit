//
//  XZMocoaKeysObserver.h
//  XZMocoa
//
//  Created by 徐臻 on 2025/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaViewModel;

@interface XZMocoaKeysObserver : NSObject

+ (XZMocoaKeysObserver *)observerForObject:(NSObject *)model;

/// 添加 keys 的事件接收者
- (void)attachReceiver:(XZMocoaViewModel *)viewModel forKeys:(NSArray<NSString *> *)keys;
/// 移除接收者。
- (void)removeReceiver:(XZMocoaViewModel *)viewModel;

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *_Nullable)context NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
