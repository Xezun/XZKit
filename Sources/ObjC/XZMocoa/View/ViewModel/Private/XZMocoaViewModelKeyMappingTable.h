//
//  XZMocoaViewModelKeyMappingTable.h
//  XZMocoa
//
//  Created by Xezun on 2025/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZObjcMethod;

/// “视图模型”监听“数据模型”的映射关系表。
@interface XZMocoaViewModelKeyMappingTable : NSObject

/// 视图模型方法名 => 数据模型属性名
/// - method -> [key1, key2]
/// - method -> [[key1,key2], [key3, key4]]
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray *>           *methodToKeys;
/// 数据模型属性名 => 视图模型方法名
/// - key -> [method1, method2]
@property (nonatomic, readonly) NSDictionary<NSString *, NSSet<NSString *> *> *keyToMethods;
/// 视图模型方法名 => XZObjcMethod
@property (nonatomic, readonly) NSDictionary<NSString *, XZObjcMethod *>      *namedMethods;

+ (nullable XZMocoaViewModelKeyMappingTable *)tableForClass:(Class)VMClass;

@end

NS_ASSUME_NONNULL_END
