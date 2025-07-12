//
//  XZMocoaKeysObserver.h
//  XZMocoa
//
//  Created by 徐臻 on 2025/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaViewModel;

/// 将一个 Runloop 内的 KVO 事件合并收集起来，并统一发送给接收者。
@interface XZMocoaKeysObserver : NSObject

+ (XZMocoaKeysObserver *)observerForObject:(NSObject *)model;

/// 添加 keys 的事件接收者。
///
/// 在此方法返回前，接收者会立即接收到新添加的 keys 的事件，不包含已经观察中的 keys 。
- (void)attachReceiver:(XZMocoaViewModel *)viewModel forKeys:(NSArray<NSString *> *)keys;
/// 移除接收者。
- (void)detachReceiver:(XZMocoaViewModel *)viewModel;

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *_Nullable)context NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
