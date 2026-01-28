//
//  XZJSONDefines.h
//  Pods
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// XZJSON 功能协议
@protocol XZJSONCoding <NSObject>

@optional

/// 模型属性与 JSON 数据键之间的映射。
///
/// > 使用 KVC 取值，这意味着，可使用 KVC 的相关规则。比如通过 `@count` 取字典的元素个数，或 `@avg.amount` 取平均值等。
///
/// - SeeAlso: [Key-Value Coding Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/)
///
/// If the key in JSON or Dictionary does not match to the model's property name, implements this method and returns the additional mapper.
///
/// 例如，对于下述数据结构。
///
/// ```json
/// {
///     "n": "Harry Pottery",
///     "p": 256,
///     "ext": { "desc": "A book written by J.K.Rowling." },
///     "ID": 100010
/// }
/// ```
///
/// 可以像下面这样定义数据模型。
///
/// ```swift
/// class Foobar: NSObject, XZJSONCoding {
///     var name: String
///     var page: Int
///     var desc: String
///     var bookID: String
///     static var mappingJSONCodingKeys: [String: Any]? {
///         return [
///             "name": "n",
///             "page": "p",
///             "desc": "ext.desc",
///             "bookID": ["id", "ID", "book_id"]
///         ]
///     }
/// }
/// ```
/// > 在 keyPath 中，反斜杠为转义字符。例如 `@"foo.bar"` 会认为是 keyPath 而 `@"foo\\.bar"` 则认为是 key 。
@property (class, readonly, nullable) NSDictionary<NSString *, id> *mappingJSONCodingKeys;

/// 无法推断类型的属性，比如属性为集合或 id 类型，可通过此方法，设置属性名与属性类型（或集合的元素类型）之间的映射关系。
///
/// 如果集合包含多种类型，可以指定一个类（比如基类），通过``-forwardingClassForJSONDictionary:``方法，转发模型化过程。
///
/// ```swift
/// import XZShadow, XZBorder;
///
/// class XZAttributes: NSObject, XZJSONCoding {
///     var name: String
///     var shadows: [XZShadow]
///     var borders: [XZBorder]
///     var attachments: [XZAttachment]
///
///     var mappingJSONCodingClasses: [String: Any]? {
///         return [
///             "shadows" : XZShadow.self,
///             "borders" : XZBorder.self,
///             "attachments" : "XZAttachment" // Use the model class name
///         ];
///     }
/// }
/// ```
@property (class, readonly, nullable) NSDictionary<NSString *, id> *mappingJSONCodingClasses;

/// 不可模型化与序列化的模型属性名的集合。
///
/// All the properties in blocked list will be ignored in model transform process.
/// Returns nil to ignore this feature.
@property (class, readonly, nullable) NSArray<NSString *> *blockedJSONCodingKeys;

/// 只可模型化或序列化的模型属性名的集合。
///
/// If a property is not in the allowed list, it will be ignored in model transform process.
/// Returns nil to ignore this feature.
@property (class, readonly, nullable) NSArray<NSString *> *allowedJSONCodingKeys;

#pragma mark - XZJSONDecoder

@optional
/// 转发数据到其它模型。
/// - Parameter dictionary: 字典形式的 JSON 数据
+ (nullable Class)forwardingClassForJSONDictionary:(NSDictionary *)dictionary;

/// 模型化之前的数据校验，一般为初步校验，比如校验统一格式等。
/// - Parameter dictionary: 字典形式的 JSON 数据
/// - Returns: 返回 nil 表示无效数据，不进行模型化。
+ (nullable NSDictionary *)canDecodeFromJSONDictionary:(NSDictionary *)dictionary;

/// 自定义 JSON 数据模型化方法。如果需要自定义模型化过程，或者模型校验，可实现此方法。
///
/// ```objc
/// - (BOOL)decodeFromJSONDictionary:(NSDictionary *)dictionary {
///     // 验证 JSON 数据是否合法
///     if (![dictionary[@"type"] isKindOfClass:NSNumber.class]) {
///         return NO;
///     }
///
///     // 调用自定义的指定初始化方法，完成初始化。
///     self = [self initWithBar:[dictionary[@"type"] intValue]];
///     if (self == nil) {
///         return NO;
///     }
///
///     // 使用 XZJOSN 进行模型化，可选。
///     // 在 XZJSON 模型化的基础上，再进行自定义模型化的过程，以减少代码量，当然也可以完全自定义这个过程。
///     [XZJSON object:self decodeWithDictionary:dictionary];
///
///     // 验证模型是否正确，可选。
///     if (self.foo == nil) {
///         return NO;
///     }
/// 
///     return YES;
/// }
/// ```
///
/// > 如果不实现此方法，则使用 `init` 方法初始化模型对象，因此自定义了指定初始化方法的模型对象，需要实现此方法，否则指定初始化方法不会被调用。
/// - Parameter dictionary: 字典形式的 JSON 数据
/// - Returns: 模型化是否成功，如果返回 NO 则该模型可能会被丢弃
- (BOOL)decodeFromJSONDictionary:(NSDictionary *)dictionary;

/// 自定义属性值解析。
///
/// - 当 XZJSON 无法将 JSON 值无法解析为属性值时，此方法会被调用。
/// - 当 XZJSON 在实现 NSCoding 遇到无法解档的属性值时，此方法会被调用，
///
/// - Parameters:
///   - value: 待处理的值，可能是 JSON 值，或包含属性值的 NSCoder 归档对象
///   - key: 属性名
/// - Returns: 返回 NO 表示未处理，返回 YES 表示已处理
- (BOOL)JSONDecodeValue:(id)value forKey:(NSString *)key;

#pragma mark - XZJSONEncoder

@optional
/// 自定义模型 JSON 序列化方法。自定义模型校验、实例序列化为数据字典的过程，可实现此方法。
/// ```objc
/// - (nullable NSDictionary *)encodeIntoJSONDictionary:(NSMutableDictionary *)dictionary {
///     [XZJSON object:self encodeIntoDictionary:dictionary];
///     dictionary[@"date"] = @(NSDate.date.timeIntervalSince1970); // 自定义：向序列化数据中，加入一个时间戳
///     return dictionary;
/// }
/// ```
/// - Note: 如果需要校验 XZJSON 序列化的结果，也可以通过此方法实现。
/// - Parameter dictionary: 字典形式的 JSON 数据
- (nullable NSMutableDictionary *)encodeIntoJSONDictionary:(NSMutableDictionary *)dictionary;

/// 需要自行实现序列化过程的属性。
///
/// - 当 XZJSON 解析 NSDate/NSData/NSValue 类型的属性时，会优先调用此方法。
/// - 当 XZJSON 无法将属性值转换为 JSON 值时，此方法会被调用。
/// - 当 XZJSON 在实现 NSCoding 遇到无法归档的属性值时，此方法会被调用。
/// - 当 XZJSON 在实现 NSDescription 遇到无法描述的属性值时，此方法会被调用。
///
/// - Parameter key: 属性名
/// - Returns: 返回 nil 表示未处理，属性不出现在结果的 JSON 中
- (nullable id<NSCoding>)JSONEncodeValueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
