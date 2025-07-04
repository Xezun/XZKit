//
//  NSArray+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSObject;

@interface NSArray<__covariant ObjectType> (XZKit)

/// 是否包含重复元素。
/// @note 使用`-isEqual:`判断是否重复。
@property (nonatomic, readonly) BOOL xz_containsDuplicateObjects NS_SWIFT_NAME(containsDuplicateObjects);

/// 合并数组中的元素，可用于数组降维。
/// @code
/// NSArray *models = @[@"1", @"2", @"3"];
/// NSNumber *sum = [models xz_reduce:@(0) next:^id(NSNumber *result, id obj, NSInteger idx, BOOL *stop) {
///     return result.integerValue + obj.integerValue;
/// }];
/// XZLog(@"%@", sum); // prints 6
/// @endcode
/// @param initialValue 初始值
/// @param next 执行数组元素合并的块函数
- (nullable id)xz_reduce:(nullable id)initialValue next:(id _Nullable(^NS_NOESCAPE)(id _Nullable result, ObjectType obj, NSInteger idx, BOOL *stop))next OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 遍历并将结果返回结果生成新的数组。
/// @note 生成的新数组元素个数与原数组相同。
/// @param transform 遍历数组元素的块函数
/// @returns 块函数返回值组成的数组，与原数组元素是一一对应的
- (NSMutableArray *)xz_map:(id _Nonnull (^NS_NOESCAPE)(ObjectType obj, NSInteger idx, BOOL *stop))transform OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 遍历并将结果返回结果生成新的数组，返回 nil 则该结果被忽略。
/// @note 生成的新数组的元素个数可能比原数少。
/// @param transform 遍历数组元素的块函数
/// @returns 块函数返回值组成的数组，可能比原数组元素少
- (NSMutableArray *)xz_compactMap:(id _Nullable (^NS_NOESCAPE)(ObjectType obj, NSInteger idx, BOOL * _Nonnull stop))transform OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 过滤掉 isIncluded 返回 NO 的对象。
/// @param isIncluded 遍历数组的块函数，返回 NO 则元素被过滤（不添加到新数组中）
- (NSMutableArray<ObjectType> *)xz_filter:(BOOL (^NS_NOESCAPE)(ObjectType obj, NSInteger idx))isIncluded OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 返回第一个符合条件的元素。
/// @param isIncluded 判断是否符合条件的块函数
- (ObjectType)xz_first:(BOOL (^NS_NOESCAPE)(ObjectType obj, NSInteger idx))isIncluded OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 返回最后一个符合条件的元素。
/// @param isIncluded 判断是否符合条件的块函数
- (ObjectType)xz_last:(BOOL (^NS_NOESCAPE)(ObjectType obj, NSInteger idx))isIncluded OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 是否包含 isIncluded 返回 YES 的元素。
/// @param isIncluded 遍历数组的块函数，返回 YES 表示匹配到元素并终止遍历
- (BOOL)xz_contains:(BOOL (^NS_NOESCAPE)(ObjectType obj, NSInteger idx))isIncluded OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 查找第一个符合条件的对象。如果没有找到，返回 NSNotFound 值。
/// @param predicate 判断条件
- (NSInteger)xz_firstIndex:(BOOL (^NS_NOESCAPE)(ObjectType obj))predicate OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 将当前数组与另一数组进行比较，分析当前数组与目标数组之间的差异。
/// @discussion 原生提供了`-differenceFromArray:`差异分析方法，但是本方法并非原生方法的间接调用。
/// @discussion 使用 `-isEqual:` 方法判断元素是否相同。
/// @param oldArray 被比较的数组，原始数组
/// @param inserts 新添加的元素在@b当前数组@c中的`index`
/// @param deletes 被删除的元素在@b原始数组@c中的`index`
/// @param changes 保留的元素中`index`发生变化的元素，`key`为在@b当前数组@c中的`index`，`value`为在@b原始数组@c中的index
/// @param remains 保留的元素中`index`保持不变的元素
- (void)xz_differenceFromArray:(NSArray *)oldArray inserts:(nullable NSMutableIndexSet *)inserts deletes:(nullable NSMutableIndexSet *)deletes changes:(nullable NSMutableDictionary<NSNumber *, NSNumber *> *)changes remains:(nullable NSMutableIndexSet *)remains NS_REFINED_FOR_SWIFT;

@end

@interface NSMutableArray<ObjectType> (XZKit)

- (nullable ObjectType)xz_removeLastObject OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");
- (ObjectType)xz_removeObjectAtIndex:(NSUInteger)index OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

@end


@interface NSArray (XZJSON)

/// 将二进制或字符串形式的 JSON 数据解析为 NSArray 对象。
/// @note JSON 数据顶层必须为数组。
/// @note 使用可变容器始构造，则 JSON 数据内的值，也为可变容器。
/// @param json 待解析的 JSON 数据
/// @param options 序列化选项
+ (nullable instancetype)xz_arrayWithJSON:(nullable id)json options:(NSJSONReadingOptions)options NS_SWIFT_NAME(init(JSON:options:));

/// 将二进制或字符串形式的 JSON 数据解析为 NSArray 对象。
/// @note 使用`NSJSONReadingAllowFragments`序列化选项。
/// @param json 待解析的 JSON 数据
+ (nullable instancetype)xz_arrayWithJSON:(nullable id)json NS_SWIFT_NAME(init(JSON:));

@end

@interface NSMutableArray (XZJSON)

@end

NS_ASSUME_NONNULL_END
