//
//  NSURL+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZURLQueryComponent;

@interface NSURL (XZKit)

@property (nonatomic, strong, readonly) XZURLQueryComponent *xz_queryComponet;

@end


@interface XZURLQueryComponent : NSObject

@property (nonatomic, strong, readonly) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic, copy) NSDictionary<NSString *, id> *keyedValues;

- (nullable id)valueForQuery:(NSString *)query;

- (void)setValue:(nullable id)value forQuery:(NSString *)query;
- (void)addValue:(nullable id)value forQuery:(NSString *)query;

- (void)removeValue:(nullable id)value forQuery:(NSString *)query;
- (void)removeValuesForQuery:(NSString *)query;

- (void)removeAllQueries;

- (BOOL)containsQuery:(NSString *)query;

- (void)addValuesForKeysFromObject:(nullable id)object;
- (void)setValuesForKeysWithObject:(nullable id)object;

- (nullable id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
