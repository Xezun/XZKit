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
/// If the key in JSON/Dictionary does not match to the model's property name, implements this method and returns the additional mapper.
///
/// @code
/// {
///     "n": "Harry Pottery",
///     "p": 256,
///     "ext": { "desc": "A book written by J.K.Rowling." },
///     "ID": 100010
/// }
/// @endcode
///
/// @code
/// @interface XZBook : NSObject <XZJSONCoding>
/// @property NSString *name;
/// @property NSInteger page;
/// @property NSString *desc;
/// @property NSString *bookID;
/// @end
///
/// @implementation XZBook
/// + (NSDictionary *)mappingJSONCodingKeys {
///     return @{
///         @"name"  : @"n",
///         @"page"  : @"p",
///         @"desc"  : @"ext.desc", // 符号 . 会认为是 keyPath 如果不是，可以使用反斜杠转义，比如 @"ext\\.desc"。
///         @"bookID": @[@"id", @"ID", @"book_id"]
///     };
/// }
/// @end
/// @endcode
///
/// @todo 如果属性对应的键不合法，那么该属性会在 JSON 处理中被忽略。
@property (class, readonly, nullable) NSDictionary<NSString *, id> *mappingJSONCodingKeys;

/// 模型属性的类型不明确时，可通过此属性提供映射关系，比如属性是集合或者 id 类型。
///
/// The generic class mapper for container properties.
///
/// If the property is a container object, such as NSArray/NSSet/NSDictionary,
/// implements this method and returns a property->class mapper, tells which kind of
/// object will be add to the array/set/dictionary.
///
/// @code
/// @class XZShadow, XZBorder, XZAttachment;
///
/// @interface XZAttributes: NSObject <XZJSONCoding>
/// @property NSString *name;
/// @property NSArray *shadows;
/// @property NSSet *borders;
/// @property NSDictionary *attachments;
/// @end
///
/// @implementation XZAttributes
/// + (NSDictionary *)mappingJSONCodingClasses {
///     return @{
///         @"shadows" : [XZShadow class],
///         @"borders" : XZBorder.class,
///         @"attachments" : @"XZAttachment"
///     };
/// }
/// @end
/// @endcode
/// @return A class mapper.
@property (class, readonly, nullable) NSDictionary<NSString *, id> *mappingJSONCodingClasses;

/// 不可模型化与序列化的模型属性名的集合。
///
/// All the properties in blocked list will be ignored in model transform process.
/// Returns nil to ignore this feature.
///
/// @return An array of property's name.
@property (class, readonly, nullable) NSArray<NSString *> *blockedJSONCodingKeys;

/// 只可模型化或序列化的模型属性名的集合。
///
/// If a property is not in the allowed list, it will be ignored in model transform process.
/// Returns nil to ignore this feature.
///
/// @return An array of property's name.
@property (class, readonly, nullable) NSArray<NSString *> *allowedJSONCodingKeys;

@end

@protocol XZJSONDecoding <XZJSONCoding>
@optional
/// 转发数据到其它模型。
/// - Parameter JSON: 字符串或二进制形式的原始 JSON 数据，或已序列化的字典或数组数据
+ (nullable Class)forwardingClassForJSONDictionary:(NSDictionary *)JSON;

/// 模型化之前的数据校验，一般为初步校验，比如校验统一格式等。
/// - Parameter JSON: 字符串或二进制形式的原始 JSON 数据，或已序列化的字典或数组数据。
/// - Returns: 返回 nil 表示无效数据，不进行模型化。
+ (nullable NSDictionary *)canDecodeFromJSONDictionary:(NSDictionary *)JSON;

/// JSON 数据模型初始化方法。如果需要自定义模型化过程，或者模型校验，可实现此方法。
/// @code
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
/// @endcode
/// @note 如果不实现此方法，则使用 `init` 方法初始化模型对象，因此自定义了指定初始化方法的模型对象，需要实现此方法，否则指定初始化方法不会被调用。
/// @param JSON 字符串或二进制形式的原始 JSON 数据，或已序列化的字典或数组数据
- (nullable instancetype)initWithJSONDictionary:(NSDictionary *)JSON;
@end

@protocol XZJSONEncoding <XZJSONCoding>
@optional
/// 自定义或校验模型实例序列化为数据字典。
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
@end

NS_ASSUME_NONNULL_END
