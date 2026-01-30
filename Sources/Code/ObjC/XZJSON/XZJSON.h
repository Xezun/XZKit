//
//  XZJSON.h
//  XZJSON
//
//  Created by Xezun on 2024/9/28.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZJSONDefines.h>
#else
#import "XZJSONDefines.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 支持模型对象与 JSON 数据互相转换的工具类。
///
/// ### 关于模型属性
/// - 模型转换依赖于 `setter` 方法，所以只读属性会被忽略。
/// - 通用逻辑无法处理弱引用关系，所以使用 `weak`、`unsafe_unretained` 或 `assign` 修饰的对象属性会被忽略。
///
/// ### 数据转换规则
/// - 基础数据类型，如 int、float、double 等类型或 NSInteger、CGFloat 等类型别名。
///     - 数字。
///     - 字符串。
/// - 内置结构体 CGRect、CGSize、CGPoint、UIEdgeInsets、CGVector、CGAffineTransform、NSDirectionalEdgeInsets、UIOffset 等。
///     - 使用 `NSStringFrom<Type>` 函数转换为字符串
///     - 使用 `<Type>FromString` 函数转换为结构体。
/// - 基础类型 NSString、NSNumber 及它们的可变类型等。
/// - 集合类型 NSArray、NSDictionary、NSSet、NSOrderedSet 及它们的可变类型。
///
/// ### 高级数据类型
/// - NSURL：符合 [RFC 2396](https://datatracker.ietf.org/doc/html/rfc2396) 规范的字符串。
/// - NSDecimalNumber：十进制数字，字符串。
/// - NSData：支持如下三种类型的 JSON 数据。
///     - 严格的 base64 字符串。
///     - 符合 [RFC 2397](https://datatracker.ietf.org/doc/html/rfc2397) 规范的 URI 字符串。
///     - 符合如下格式的字符。
///     ```json
///     {
///         "type": "content-type",
///         "encoding": "base64 or hex",
///         "data": "binary data in base64 or hex encoding"
///     }
///     ```
/// - NSDate：以“秒”为单位的时间戳（整数或浮点数），或者符合 `yyyy-MM-dd HH:mm:ss` 格式的字符串。
/// - NSValue：数值或布尔值，或者类似 `{ "type": "CGRect", "value": "{{1,2},{3,4}}" }`格式的结构体的字典。
///
/// ### 自定义转换规则
/// 模型可通过 `XZJSONCoding` 协议，自定义模型转换规则，同时该协议也会用于 `NSCoding` 的归档/解档过程。
/// - ``-JSONDecodeValue:forKey:`` 自定义“数据”转“模型属性”的过程。
/// - ``-JSONEncodeValueForKey:`` 自定义“模型属性”转“数据”的过程。
///
/// ### 其它规则
/// - 字面类型数据 NSData、NSDate、NSValue 支持多种格式，但 XZJSON 只支持其中固定的两种格式，所以在处理它们时，会通过 `XZJSONCoding` 协议，优先让模型处理，模型不处理，才会执行内置解析过程。
/// - 数值类型 long double 只能转换为 JSONString 类型，但是 JSON 的 Number 可以转为 double long 类型。
/// - NSDate 类型，默认转换为 JSON Number 类型，即时间戳，转特定格式，需要自定义。
/// - 支持的结构体仅包括原生提供了 `NSStringFrom~` 和 `~FromString` 函数的结构体。
///
/// ### 特殊情况
/// - 数据不是数组，但是属性是数组类型，自动包装为 `@[data]` 形式的数组。
/// - 数据是数组，但属性是字典，自动包装为 `@{ @"index": item }` 形式的字典。
/// - 数据不是字典，但是属性是自定义模型，自动包装为 `@{ @"rawValue": data }` 形式的字典。
@interface XZJSON : NSObject

/// 默认的格式化日期转换工具，默认使用 `yyyy-MM-dd HH:mm:ss` 格式。
///
/// 建议在业务中，使用统一的日期格式，这样在程序初始化时，模型转换开始前，通过此属性设置默认日期格式，即可避免在每个模型中重复处理。
///
/// > 由于数据处理一般在子线程，这意味着，在使用时，动态修改日期格式，可能会有意外风险。
///
/// 另外，非默认的日期格式的模型，可以通过`XZJSONCoding`协议自定日期转换过程。
///
/// > 数值数据，默认当作时间戳（秒）转换为日期，即当 JSON 数据为 number 类型，模型属性为 NSDate 类型时，JSON 数据的 number 将被当作时间戳（秒）处理。
@property (class, nonatomic, readonly) NSDateFormatter *dateFormatter;

@end

#pragma mark - 数据转模型

enum {
    /// 当同时解析多个 json 数据时，希望传入的数组和传出的数组数量一致，可提供此选项。
    ///
    /// NSJSONReadingOptions 的拓展，当转换失败的数据将使用 kCFNull 占位。
    ///
    /// 此标记不影响模型的转换过程，模型的集合属性，在转换时，是否保持大小，由模型决定。
    XZJSONReadingKeepCapacity = (1UL << 63)
};

@interface XZJSON (XZJSONDecoder)

/// JSON 数据模型化。
///
/// 支持的 JSON 数据类型如下：
/// - 字符串形式的 JSON 数据。
/// - 二进制流形式的 JSON 数据。
/// - 上述两种形式 JSON 数据组成的数组。
/// - 上述三种类型数据组成的数组。
///
/// 如果序列化多个 JSON 数据，则可使用 XZJSONReadingKeepCapacity 标记，将可能会插入 `(id)kCFNull` 对象，以保持输入输出的数组元素数量一致。
///
/// - Parameters:
///   - json: JSON 数据
///   - options: 模型化 JSON 数据为模型的可选项；如果 JSON 已解析，则此参数忽略
///   - modelClass: 模型的类对象
+ (nullable id)decode:(nullable id)json options:(NSJSONReadingOptions)options class:(Class)modelClass;

/// 通用模型化过程，直接使用模型实例对象 model 对 JSON 字典数据进行模型化。
///
/// 请注意，调用此方法：
/// - 不触发参数 dictionary 的校验过程。
/// - 不触发模型化转发流程。
/// - 不触发模型自定义初始化流程。
///
/// 在自定义模型化过程时，可调用此方法，先执行通用模型化过程，然后再执行自定义过程。
///
/// ```objc
/// - (BOOL)decodeFromJSONDictionary:(NSDictionary *)dictionary {
///     // 执行通用模型化过程。
///     [XZJSON model:self decodeFromDictionary:dictionary];
///
///     // 验证模型是否正确。
///     if (self.students.count == 0) {
///         return NO;
///     }
///
///     // 处理自定义逻辑：关联学生和老师
///     for (Example05Student *student in self.students) {
///         student.teacher = self;
///     }
///
///     return YES;
/// }
/// ```
///
/// - Parameters:
///   - model: 模型实例对象
///   - dictionary: JSON 数据字典
+ (void)model:(id)model decodeFromDictionary:(NSDictionary *)dictionary;

@end

#pragma mark - 模型转数据

@interface XZJSON (XZJSONEncoder)

/// 将模型对象进行 JSON 数据化。
///
/// - Parameters:
///   - model: 模型对象，也可以是模型对象组成的数组
///   - options: 序列化模型为 JSON 数据的可选项
///   - error: 错误输出
+ (nullable NSData *)encode:(nullable id)model options:(NSJSONWritingOptions)options error:(NSError **)error;

/// 将模型实例对象 model 序列化进 JSON 字典。
///
/// 在定义模型序列化过程的方法中，可以调用此方法完成通用的序列化逻辑，然再执行自定义序列化过程。
///
/// ```objc
/// - (NSMutableDictionary *)encodeIntoJSONDictionary:(NSMutableDictionary *)dictionary {
///     [XZJSON model:self encodeIntoDictionary:dictionary];
///     dictionary[@"signature"] = @"a signature to verify this model";
///     return dictionary;
/// }
/// ```
///
/// - Parameters:
///   - model: 模型实例对象，必须为模型实例对象
///   - dictionary: 数据字典
+ (void)model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary;

@end

#pragma mark - 归档解档

@interface XZJSON (NSCoding)

/// 辅助模型归档的方法。
/// ```swift
/// class Foobar: NSObject, NSCoding {
///
///     func encode(with coder: NSCoder) {
///         XZJSON.model(self, encodeWith: coder)
///     }
///
/// }
/// ```
/// - Parameters:
///   - model: 模型
///   - aCoder: 归档工具
+ (void)model:(id)model encodeWithCoder:(NSCoder *)aCoder;

/// 辅助模型解档的方法。
/// ```swift
/// class Foobar: NSObject, NSCoding {
///
///     required init?(coder: NSCoder) {
///         super.init()
///         XZJSON.model(self, decodeWith: coder)
///     }
///
/// }
/// ```
/// - Parameters:
///   - model: 模型
///   - aCoder: 解档工具
/// - Returns: 解档成功返回对象
+ (nullable id)model:(id)model decodeWithCoder:(NSCoder *)aCoder;

@end

#pragma mark - 模型描述

@interface XZJSON (NSDescription)

/// 生成模型的描述文本。
/// - Parameter model: 待描述的模型对象
/// - Parameter indent: 输出模型时的缩进等级
+ (NSString *)model:(id)model descriptionWithIndent:(NSUInteger)indent;

@end

#pragma mark - 模型复制

@interface XZJSON (NSCopying)

/// 模型复制。仅复制可 JSON 序列化、同名且数据类型相同的属性的。
/// 
/// 以下情形，需开发者先创建 targetModel 然后作为参数传入。
/// - sourceModel 与 targetModel 的类型不同。
/// - sourceModel 使用自定义的初始化方法。
/// - sourceModel 有 JSON 无法序列化（即无法复制）的属性。
/// 
/// ```objc
/// - (id)copyWithZone:(NSZone *)zone {
///     // 使用了自定义初始化方法
///     id const newModel = [[Foobar alloc] initWithName:self.name];
/// 
///     // 无法复制的属性
///     if (self->_foobar) {
///         size_t const count = strlen(self->_foobar);
///         newModel->_foobar = calloc(count, sizeof(char));
///         strcpy(newModel->_foobar, self->_foobar);
///     }
/// 
///     // 调用 XZJSON 复制过程
///     return [XZJSON model:self copy:newModel];
/// }
/// ```
/// 
/// - Parameters:
///   - sourceModel: 被复制的模型对象。
///   - targetModel: 复制到的目标对象，如果未提供，则使用 `+[sourceModel.class new]` 方法创建。
/// - Returns: 复制后的模型对象，如果传入 targetModel 参数，则为该参数值。
+ (id)model:(id)sourceModel copy:(nullable id)targetModel;

@end

#pragma mark - 模型比较

@interface XZJSON (NSEquatable)

/// 模型比较：如果两个模型的 JSON 可序列化属性完全相同，那么就认为两个模型相等，即使两个模型的类型不同。
///
/// ```objc
/// - (BOOL)isEqual:(id)object {
///     // 自行比较不可序列化的属性
///     if (self.foo != object.bar) {
///         return NO;
///     }
///     // 可序列化的属性，由 XZJSON 进行比较
///     return [XZJSON model:self isEqual:object];
/// }
/// ```
/// 
/// - Parameters:
///   - model1: 待比较的模型。
///   - model2: 被比较的模型。
+ (BOOL)model:(nullable id)model1 isEqual:(nullable id)model2;

@end

NS_ASSUME_NONNULL_END
