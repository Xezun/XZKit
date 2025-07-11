//
//  XZMocoaKeysMapTable.h
//  XZMocoa
//
//  Created by 徐臻 on 2025/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZObjcMethodDescriptor;

@interface XZMocoaKeysMapTable : NSObject

// 方法名 => 绑定的属性 method -> [key1, key2] 或 method -> [[key1,key2], [key3, key4]]
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray *>                *methodToKeys;
// 属性名 => 包含的方法 key -> [method1, method2]
@property (nonatomic, readonly) NSDictionary<NSString *, NSSet<NSString *> *>      *keyToMethods;
// 方法名 => 方法的描述 method -> XZObjcMethodDescriptor
@property (nonatomic, readonly) NSDictionary<NSString *, XZObjcMethodDescriptor *> *namedMethods;

+ (nullable XZMocoaKeysMapTable *)mapTableForClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
