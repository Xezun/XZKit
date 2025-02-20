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
/// 可以像下面这样定义数据模型。
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
///             "desc": "ext.desc", // 点号 . 会认为是 keyPath 如果不是，可以使用反斜杠转义，比如 "ext\\.desc"。
///             "bookID": ["id", "ID", "book_id"]
///         ]
///     }
/// }
/// ```
@property (class, readonly, nullable) NSDictionary<NSString *, id> *mappingJSONCodingKeys;

/// 模型属性的类型不明确时，可通过此属性提供映射关系，比如属性是集合或者 id 类型。
///
/// > 如果集合包含多种类型，建议使用“基类”，让集合中的元素具有相同的基类，然后在基类中 fowarding 子类。
///
/// The generic class mapper for container properties.
///
/// If the property is a container object, such as NSArray/NSSet/NSDictionary,
/// implements this method and returns a property->class mapper, tells which kind of
/// object will be add to the array/set/dictionary.
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

#pragma mark - XZJSONDecoding

@optional
/// 转发数据到其它模型。
/// - Parameter JSON: 字符串或二进制形式的原始 JSON 数据，或已序列化的字典或数组数据
+ (nullable Class)forwardingClassForJSONDictionary:(NSDictionary *)JSON;

/// 模型化之前的数据校验，一般为初步校验，比如校验统一格式等。
/// - Parameter JSON: 字符串或二进制形式的原始 JSON 数据，或已序列化的字典或数组数据。
/// - Returns: 返回 nil 表示无效数据，不进行模型化。
+ (nullable NSDictionary *)canDecodeFromJSONDictionary:(NSDictionary *)JSON;

/// 自定义 JSON 数据模型化方法。如果需要自定义模型化过程，或者模型校验，可实现此方法。
///
/// ```objc
/// - (instancetype)initWithJSONDictionary:(NSDictionary *)JSON {
///     // 验证 JSON 数据是否合法
///     if (![JSON[@"type"] isKindOfClass:NSNumber.class]) {
///         return nil;
///     }
///
///     // 调用自定义的指定初始化方法，完成初始化。
///     self = [self initWithBar:[JSON[@"type"] intValue]];
///     if (self == nil) {
///         return nil;
///     }
///
///     // 使用 XZJOSN 进行模型化，可选。
///     // 在 XZJSON 模型化的基础上，再进行自定义模型化的过程，以减少代码量，当然也可以完全自定义这个过程。
///     [XZJSON object:self decodeWithDictionary:JSON];
/// 
///     // 验证模型是否正确，可选。
///     if (self.foo == nil) {
///         return nil;
///     }
/// 
///     return self;
/// }
/// ```
///
/// > 如果不实现此方法，则使用 `init` 方法初始化模型对象，因此自定义了指定初始化方法的模型对象，需要实现此方法，否则指定初始化方法不会被调用。
/// - Parameter JSON: JSON 字符串或二进制形式的原始 JSON 数据，或已序列化的字典或数组数据
- (nullable instancetype)initWithJSONDictionary:(NSDictionary *)JSON;

/// 自定义属性值解析。
///
/// - 当 XZJSON 无法将 JSON 值无法解析为属性值时，此方法会被调用。
/// - 当 XZJSON 在实现 NSCoding 遇到无法解档的属性值时，此方法会被调用，
///
/// - Parameters:
///   - valueOrCoder: 待处理的值，可能是 JSON 值，或归档的 NSCoder 对象
///   - key: 属性名
- (void)JSONDecodeValue:(id)valueOrCoder forKey:(NSString *)key;

#pragma mark - XZJSONEncoding

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
/// - Parameter JSON: 数据字典
- (nullable NSMutableDictionary *)encodeIntoJSONDictionary:(NSMutableDictionary *)JSON;

/// 需要自行实现序列化过程的属性。
///
/// - 当 XZJSON 无法将属性值转换为 JSON 值时，此方法会被调用。
/// - 当 XZJSON 在实现 NSCoding 遇到无法归档的属性值时，此方法会被调用。
/// - 当 XZJSON 在实现 NSDescription 遇到无法描述的属性值时，此方法会被调用。
///
/// - Parameter key: 属性名
- (nullable id<NSCoding>)JSONEncodeValueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
