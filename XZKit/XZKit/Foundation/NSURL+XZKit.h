//
//  NSURL+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/5/9.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZMacro.h>

NS_ASSUME_NONNULL_BEGIN
@class XZURLQuery;

@interface NSURL (XZKit)
/// 获取 URL 的查询字段对象。
@property (nonatomic, copy, readonly, nullable) XZURLQuery *xz_query;
@end

/// 通过 XZURLQuery 对象，可以更方便的处理 URL 中的查询字段。
/// @code
/// XZURLQuery *query = [XZURLQuery URLQueryWithString:@"https://xzkit.xezun.com/?name=XX&role=YY"];
/// [query setValuesForFieldsWithObject:@{
///     @"name": @"Xezun",
///     @"role": @"Developer"
/// }];
/// NSLog(@"%@", query.url); // prints https://xzkit.xezun.com/?name=Xezun&role=Developer
/// @endcode
@interface XZURLQuery : NSObject <NSCopying>

/// 原有的 URL 不会改变，必须调用此方法获取最新的 URL 对象。
@property (nonatomic, copy, readonly) NSURL *url;

- (instancetype)init NS_UNAVAILABLE;
/// 构造 URL 查询对象。
/// @discussion 请避免使用`XZURLQuery`处理查询字段的同时操作`NSURLComponents`的`queryItems`属性，否则结果将不可预料。
/// @discussion 按实际功能来说`XZURLQuery`更像是`NSURLComponents`的拓展，而非`NSURL`的拓展，因为它实际上管理的只是`NSURLComponents.queryItems`属性。
/// @discussion 按照`NSURLComponents`的API说明，每次设置`queryItems`属性都会生成`query`字符串，所以
///             为了避免额外消耗，除非调用`url`属性，否则`XZURLQuery`不会主动设置`queryItems`属性。
/// @param urlComponents `NSURLComponents`对象
- (instancetype)initWithURLComponents:(NSURLComponents *)urlComponents NS_DESIGNATED_INITIALIZER;
/// 构造 URL 查询对象。
/// @param url `NSURL`对象，相对地址可能返回`nil`
+ (nullable instancetype)URLQueryForURL:(nullable NSURL *)url;
/// 构造 URL 查询对象。
/// @param url `NSURL`对象
/// @param resolve 第一个参数的`NSURL`对象是否为相对地址
+ (nullable instancetype)URLQueryForURL:(nullable NSURL *)url resolvingAgainstBaseURL:(BOOL)resolve;
/// 通过 URL 字符串构造查询对象。
/// @param urlString URL 字符串
+ (nullable instancetype)URLQueryWithString:(nullable NSString *)urlString;

/// 将任意值解析为查询字段的值。
/// @discussion `nil`或`NSNull`会触发一次`nil`回调。
/// @discussion `NSString`对象，直接触发一次回调。
/// @discussion `NSNumber`对象，获取`stringValue`的结果触发一次回调。
/// @discussion `NSDate`对象，转换为时间戳（秒）字符串并触发一次回调。
/// @discussion `NSArray`对象，按照上述规则对每一个值触发一次回调。
/// @discussion 其它类型的值不支持，触发`NSAssert`异常。
/// @param value 任意值
/// @param block 接收值的块函数
+ (void)parseFieldValue:(id)value byUsingBlock:(void (^NS_NOESCAPE)(NSString * _Nullable value))block;

/// 返回查询字段的字典形式，键为查询字段名，值为查询字段值。
/// @note 无值的查询字段返回 NSNull 对象，多值的查询字段返回数组对象，即值可能为 NSString 或 NSNull 或二者组成的数组。
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *dictionaryRepresentation;

/// 获取查询字段值。
/// @note 返回值为 NSString 或 NSString 数组，数组可能包含 NSNull 对象。
/// @note 不会直接返回 NSNull 所以返回 nil 不代表这个查询字段不存在。
/// @param field 查询字段名
- (nullable id)valueForField:(NSString *)field;
/// 设置查询字段，将覆盖已有值。
/// @param value 查询字段值
/// @param field 查询字段名
- (void)setValue:(nullable id)value forField:(NSString *)field;
/// 添加查询字段。
/// @param value 查询字段值
/// @param field 查询字段名
- (void)addValue:(nullable id)value forField:(NSString *)field;

/// 移除单个查询字段，同时匹配键值，如果没有匹配项，则不执行任何操作。
/// @param value 查询字段值
/// @param field 查询字段名
- (void)removeValue:(nullable id)value forField:(NSString *)field;

/// 移除查询字段，包括字段名名及所有对应的所有值。
/// @param field 查询字段名
- (void)removeField:(NSString *)field;

/// 移除所有查询字段。
- (void)removeAllFields;

/// 是否包含查询字段。
/// @param field 查询字段名
- (BOOL)containsField:(NSString *)field;

/// 添加查询字段。
/// @discussion 字典：键值将分别作为查询字段的名和值。
/// @discussion 数组：数组元素将作为查询字段的名，没有值。
/// @note 不会删除已有同名字段。
/// @param object 字典或数组对象
- (void)addValuesForFieldsFromObject:(nullable id)object;

/// 设置查询字段。
/// @discussion 字典：键值分别为查询字段名和值。
/// @discussion 数组：元素为查询字段名。
/// @param object 字典或数组对象
- (void)setValuesForFieldsWithObject:(nullable id)object;

/// 获取查询字段值，返回值为 NSString 或 NSString 数组，可能包含 NSNull 对象。
/// @code
/// XZURLQuery *query = [XZURLQuery URLQueryWithString:@"https://xzkit.xezun.com/?name=XZKit"];
/// NSLog(@"%@", query[@"name"]); // prints XZKit
/// @endcode
/// @param field 查询字段名
- (nullable id)objectForKeyedSubscript:(NSString *)field;
/// 设置查询字段，将覆盖已有值。
/// @code
/// XZURLQuery *query = [XZURLQuery URLQueryWithString:@"https://xzkit.xezun.com/"];
/// query[@"name"] = @"XZKit"; // set a query field name=XZKit
/// @endcode
/// @param obj 查询字段值
/// @param field 查询字段名
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)field;

@end

NS_ASSUME_NONNULL_END
