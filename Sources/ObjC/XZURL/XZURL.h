//
//  XZURL.h
//  XZURL
//
//  Created by Xezun on 2023/7/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 对 NSURLComponents 的封装，以方便对 URL 进行修改，特别是对 query 部件的增删改查。
@interface XZURL : NSObject

/// 通过 NSURL 对象构造 XZURL 对象。
/// - Parameter url: NSURL 对象
+ (nullable instancetype)URLWithURL:(nullable NSURL *)url NS_SWIFT_NAME(init(_:));

/// 通过 URL 字符串构造 XZURL 对象。
/// - Parameter URLString: URL 字符串
+ (nullable instancetype)URLWithURLString:(nullable NSString *)URLString NS_SWIFT_NAME(init(_:));

/// 通过 `NSURLComponents` 对象构造 XZURL 对象。
///
/// 将持有的 `NSURLComponents` 的复制份，而非原始对象，因此对原始对象 `components` 的修改不会同步到 `XZURL` 中。
/// - Parameter components: NSURLComponents 对象
+ (instancetype)URLWithComponents:(NSURLComponents *)components NS_SWIFT_NAME(init(_:));

/// 获取实时的 NSURL 对象。
/// 当修改 XZURL 之后，调用此方法即可获修改后的 NSURL 对象。
@property (nonatomic, copy, readonly, nullable) NSURL *URL;

@property (nullable, copy) NSString *scheme;
@property (nullable, copy) NSString *user;
@property (nullable, copy) NSString *password;
@property (nullable, copy) NSString *host;
@property (nullable, copy) NSNumber *port;
/// 由于 NSURLComponents 的原因，此属性可能返回空字符串，而不是 nil 值。
@property (nullable, copy) NSString *path;
@property (nullable, copy) NSString *query;
@property (nullable, copy) NSString *fragment;

/// 以字典形式返回所有字段。
///
/// 字典的值，即字段值，只有如下三种形式。
/// | Query形式 | 值类型 |
/// |:-------------------------|:--------:|
/// | `?key=value`             | NSString |
/// | `?key=value1&key=value2` | NSArray  |
/// | `?key`                   | NSNull   |
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *allQueryFields;

/// 读取字段值，值可能为 `NSString *` 或 `NSArray<NSString *> *` 类型。
///
/// 返回值为字段的实时值。
///
/// 此方法不会返回 NSNull 对象，而是直接返回 nil 值，所以判断是否包含某字段需用 `-containsValueForQueryField:` 方法。
/// - Parameter field: 字段名
- (nullable id)valueForQueryField:(NSString *)field;

/// 设置字段值。
///
/// @li 设置 nil、空 NSArray 数组、空 NSSet 集合 等值，都表示删除字段。
/// @li 设置 `NSNull` 表示字段值为 `nil` 值。
/// @li 设置 `NSArray` 表示设置多个同名字段，字段值分别为数组中的元素。
/// @li 非 `NSString` 或 `NSNull` 的数据，会转化为 JSON 字符串，若不能 JSON 序列化，则使用数据的 `description` 属性值。
///
/// @param value 字段值
/// @param field 字段名
- (void)setValue:(nullable id)value forQueryField:(NSString *)field;

/// 添加字段值。
/// @seealso 规则同 ``-setValue:forQueryField`` 方法。
/// @param value 字段值
/// @param field 字段名
- (void)addValue:(nullable id)value forQueryField:(NSString *)field;

/// 移除所有字段。
- (void)removeAllQueryFields;

/// 下标取值方法。等同于 -valueForName: 方法。
- (nullable id)objectForKeyedSubscript:(NSString *)field;

/// 下标设值方法，效果等同于 -setValue:forField: 方法。
- (void)setObject:(nullable id)value forKeyedSubscript:(NSString *)field;

/// 是否包含字段，包括值为 `nil` 的字段。
/// - Parameter field: 字段名
- (BOOL)containsValueForQueryField:(NSString *)field;

/// 获取字段字符串值。如果字段包含多个值，返回第一个字符串值。
/// - Parameter field: 字段名
- (nullable NSString *)stringValueForQueryField:(NSString *)field;

/// 获取字段数组值。如果不包含字段，返回 nil 值；如果字段值不是数组，则将值包装为数组。
/// - Parameter field: 字段名
- (nullable NSArray *)arrayValueForQueryField:(NSString *)field;

/// 获取字段整数值，将字符串转为整数。
/// - Parameter field: 字段名
- (NSInteger)integerValueForQueryField:(NSString *)field;

/// 获取字段浮点值，将字符串转为浮点值。
/// - Parameter field: 字段名
- (CGFloat)floatValueForQueryField:(NSString *)field;

/// 获取字段 NSURL 值，将字符串构造为 NSURL 对象。
/// - Parameter field: 字段名
- (nullable NSURL *)urlValueForQueryField:(NSString *)field;

/// 将字典的 key/value 分别作为字段的 name/value 添加到 query 中。
/// - Parameter dictionary: 要添加到 query 的字典
- (void)addValuesForQueryFieldsWithDictionary:(nullable NSDictionary<NSString *, id> *)dictionary;

/// 将字典的 key/value 分别作为字段的 name/value 设置到 query 中。
/// - Parameter dictionary: 要添加到 query 的字典
- (void)setValuesForQueryFieldsWithDictionary:(nullable NSDictionary<NSString *, id> *)dictionary;

@end

@interface NSURL (XZURL)

/// 这是一个计算属性，每次都会重新生成一个新的 XZURL 对象。
@property (nonatomic, readonly) XZURL *XZURL NS_SWIFT_NAME(xzURL);

@end

NS_ASSUME_NONNULL_END
