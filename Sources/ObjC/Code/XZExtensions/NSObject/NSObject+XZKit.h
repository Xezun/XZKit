//
//  NSObject+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @define 遍历对象的块函数形式。
/// @param value 被遍历的值
/// @param keyPath 值的路径
/// @param stop 控制是否停止遍历的标记
typedef void (^XZKeyPathEnumerator)(id _Nullable value, NSString *keyPath, BOOL *stop);
/// @define 处理对象路径值的块函数形式。
/// @param value 被遍历的值
/// @param keyPath 值的路径
/// @param stop 控制是否停止遍历的标记
typedef id _Nullable (^XZKeyPathTransformer)(id _Nullable value, NSString *keyPath, BOOL *stop);
/// @define 比较查找对象路径值的块函数形式。
/// @param value 被遍历的值
/// @param keyPath 值的路径
/// @param stop 控制是否停止遍历的标记
typedef BOOL (^XZKeyPathComparator)(id _Nullable value, NSString *keyPath, BOOL *stop);

@interface NSObject (XZKeyPathEnumeration)
@end

@interface NSArray (XZKeyPathEnumeration)
@end

@interface NSSet (XZKeyPathEnumeration)
@end

@interface NSObject (XZKit)

/// 遍历对象中指定的路径的值。
///
/// @discussion
/// 使用 KVC 来获取路径的中间值，并通过 `@try-catch` 拦截了 KVC 异常。
///
/// @discussion
/// 如果中间值为 `NSArray` 或 `NSSet` 集合对象，那么 KVC 执行对象为其内元素，而非集合对象本身。
///
/// @discussion
/// 比如，对于有如下三层结构的`Table`对象：
///
/// @code
/// @interface Table : NSObject
/// @property (nonatomic, copy) NSURL *url;
/// @property (nonatomic, copy) NSArray<Section *> *sections;
/// @end
///
/// @interface Section : NSObject
/// @property (nonatomic, copy) NSURL *url;
/// @property (nonatomic, copy) NSArray<Cell *> *rows;
/// @end
///
/// @interface Cell : NSObject
/// @property (nonatomic, copy) NSURL *url;
/// @end
/// @endcode
///
/// @discussion 遍历其中所有的`url`则可以使用本方法。
///
/// @code
/// [table xz_enumerateValuesForKeyPaths:@[
///     @"table.url",
///     @"table.sections.url",
///     @"table.sections.rows.url"
/// ] usingBlock:^(NSURL *url, BOOL *stop){
///     XZLog(@"%@", url);
/// }];
/// @endcode
///
/// @discussion
/// 使用 `-xz_mapValuesForKeyPaths:usingBlock:` 方法，可以提取所有遍历的对象。
///
/// @param enumerator 遍历时调用的块函数
/// @param keyPaths 遍历的路径
- (void)xz_enumerateValuesForKeyPaths:(NSArray<NSString *> *)keyPaths usingBlock:(NS_NOESCAPE XZKeyPathEnumerator)enumerator NS_SWIFT_NAME(enumerateValues(forKeyPaths:using:));

/// 遍历对象的指定路径上的值，并将结果作为集合返回。
/// @seealso 请参考方法 `-xz_enumerateValuesForKeyPaths:usingBlock:` 获取更多使用说明。
/// @param transformer 收集值的块函数
/// @param keyPaths 待收集的值在对象中的路径
- (NSMutableArray *)xz_mapValuesForKeyPaths:(NSArray<NSString *> *)keyPaths usingBlock:(NS_NOESCAPE XZKeyPathTransformer)transformer NS_SWIFT_NAME(mapValues(forKeyPaths:using:));

/// 判断在对象的指定路径上，是否存在符合指定条件的值。
/// @seealso 请参考方法 `-xz_enumerateValuesForKeyPaths:usingBlock:` 获取更多使用说明。
/// @note 如果遍历提前终止，则返回块函数 isIncluded 终止时的返回值。
/// @param comparator 判断值
/// @param keyPaths 值所在的路径
- (BOOL)xz_containsValuesForKeyPaths:(NSArray<NSString *> *)keyPaths usingBlock:(NS_NOESCAPE XZKeyPathComparator)comparator NS_SWIFT_NAME(containsValues(forKeyPaths:where:));

@end

@class NSPredicate;

NS_ASSUME_NONNULL_END
