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
/// - 通用逻辑无法处理弱引用关系，所以 `unsafe_unretained` 或 `assign` 修饰的对象的属性会被忽略。
///
/// ### 基础数据类型
/// - 所有 C 基础数据类型，比如 int、float、double 等，包括 NSInteger、CGFloat、CGRect 等类型别名和结构体。
/// - 基础类型 NSString、NSNumber 及它们的可变类型等。
/// - 集合类型 NSArray、NSDictionary、NSSet、NSOrderedSet 及它们的可变类型。
/// - 字面类型 NSURL、NSDecimalNumber、NSData、NSDate、NSValue 及 NSString 数字。
///
/// ### 高级数据类型
/// - NSURL：符合 [RFC 2396](https://datatracker.ietf.org/doc/html/rfc2396) 规范的字符串
/// - NSDecimalNumber：十进制数字
/// - NSData：严格的 base64 字符串，或符合 [RFC 2397](https://datatracker.ietf.org/doc/html/rfc2397) 规范的 URI 字符串，或者格式如 `{ "type": "base64", "data": "base64" }` 字典，当前仅支持 hex 和 base64 编码。
/// - NSDate：以“秒”为单位的时间戳（整数或浮点数），或者符合 `yyyy-MM-dd HH:mm:ss` 格式的字符串。
/// - NSValue：数值或布尔值，或者类似 `{ "type": "CGRect", "value": "{{1,2},{3,4}}" }`格式的结构体的字典。
///
/// ### 自定义转换规则
/// 模型可通过 `XZJSONCoding` 协议，自定义模型转换规则，同时该协议也会用于 `NSCoding` 的归档/解档过程。
/// - ``-JSONDecodeValue:forKey:`` 自定义“数据”转“模型属性”的过程
/// - ``-JSONEncodeValueForKey:`` 自定义“模型属性”转“数据”的过程
///
/// ### 其它规则
/// - 字面类型数据 NSData、NSDate、NSValue 支持多种格式，但 XZJSON 只支持其中固定的两种格式，所以在处理它们时，会通过 `XZJSONCoding` 协议，优先让模型处理，模型不处理，才会执行内置解析过程。
/// - 数值类型 long double 只能转换为 JSONString 类型，但是 JSONNumber 可以转为 double long 类型。
/// - NSDate 类型，默认转换为 JSONNumber 时间戳，转特定格式，需要自定义。
/// - 支持的结构体仅包括原生提供了 `NSStringFrom~` 和 `~FromString` 函数的结构体。
///
/// ### 特殊情况
/// - 数据不是数组，但是属性是数组类型，自动包装为 `@[data]` 形式的数组。
/// - 数据是数组，但属性是字典，自动包装为 `@{ @"index": item }` 形式的字典。
/// - 数据不是字典，但是属性是自定义模型，自动包装为 `@{ @"rawValue": data }` 形式的字典。
@interface XZJSON : NSObject
/// “字符串-日期”转换的默认格式化工具，默认 `yyyy-MM-dd HH:mm:ss` 格式。
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

@interface XZJSON (XZJSONDecoder)
/// JSON 数据模型化。
///
/// 参数 json 支持的类型：
///
/// - JSON 字符串
/// - JSON 二进制流
/// - JSON 字符串或 JSON 二进制流组成的数组
///
/// - Parameters:
///   - json: JSON 数据
///   - options: JSON 读取选项，如果 JSON 已解析，则此参数忽略
///   - class: 模型的类对象
+ (nullable id)decode:(nullable id)json options:(NSJSONReadingOptions)options class:(Class)aClass;

/// 使用模型实例对象 model 对 JSON 字典数据进行模型化。
///
/// - Parameters:
///   - model: 模型实例对象
///   - dictionary: JSON 数据字典
+ (void)model:(id)model decodeFromDictionary:(NSDictionary *)dictionary;
@end

@interface XZJSON (XZJSONEncoder)
/// 将任意实例对象进行 JSON 数据化。
///
/// - Parameters:
///   - object: 任意对象
///   - options: JSON 生成选项
///   - error: 错误输出
+ (nullable NSData *)encode:(nullable id)object options:(NSJSONWritingOptions)options error:(NSError **)error;

/// 将模型实例对象 model 序列化进 JSON 字典。
///
/// > 参数 model 必须为模型实例对象。
///
/// - Parameters:
///   - model: 模型实例对象
///   - dictionary: 数据字典
+ (void)model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary;
@end

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


@interface XZJSON (NSDescription)
/// 生成模型的描述文本。
/// - Parameter model: 待描述的模型对象
/// - Parameter indent: 输出模型时的缩进等级
+ (NSString *)model:(id)model description:(NSUInteger)indent;
@end


@interface XZJSON (NSCopying)

/// 模型复制，仅复制同名、且数据类型相同的属性。
/// 
/// > 模型使用 `+[Class new]` 方法创建新的模型对象，因此模型如果需要特殊的初始化方法，可重写此方法。
///
/// 结构体、共用体、C指针等类型的属性，由于存在无法确定内存管理方式，或无法确定数据大小等情况，所以需要在 block 中自行实现复制方式。
///
/// ```objc
/// - (id)copyWithZone:(NSZone *)zone {
///     return [XZJSON model:self copy:^BOOL(Foo *newModel, NSString * _Nonnull key) {
///         if ([key isEqualToString:@"foo"]) {
///             if (self->_foo) {
///                 size_t const count = strlen(self->_foo);
///                 newModel->_foo = calloc(count, sizeof(char));
///                 strcpy(newModel->_foo, self->_foo);
///             }
///             return YES;
///         }
///         return NO;
///     }];
/// }
/// ```
///
/// 如果超类已经调用此方法实现了 NSCopying 协议，那么子类不宜直接调用此方法，而是像下面这样处理，否则子类就需要在 block 中重新处理超类中“无法确定复制方式”的属性。
///
/// ```objc
/// - (void)copyWithZone:(NSZone *)zone {
///     Bar *newModel = [super copyWithZone:zone];
///     newModel.bar = self.bar;
/// }
/// ```
/// - Parameter model: 被复制的模型对象
/// - Parameter block: 需要自行实现复制的属性，返回 NO 标识未处理，控制台将输出未处理的输出
/// - Returns: 复制后的模型对象
+ (id)model:(id)model copy:(BOOL (^_Nullable)(id newModel, NSString *key))block;

@end

@interface XZJSON (NSEquatable)

/// 模型比较。如果模型的属性相同，则认为模型相等，即使模型的类型不同。
///
/// 块函数返回值各枚举值含义：
/// - NSOrderedSame 相等
/// - NSOrderedAscending 不相等
/// - NSOrderedDescending 未比较
///
/// - Parameters:
///   - model1: 待比较的模型
///   - model2: 被比较的模型
///   - block: 如果属性值无法比较，将调用此块函数，如不提供，则认为属性不相等。
+ (BOOL)model:(id)model1 isEqualToModel:(id)model2 comparator:(NSComparisonResult (^_Nullable)(id model1, id model2, NSString *key))block;

+ (NSArray<NSString *> *)model:(id)model compareToModel:(id)newModel;


@end

NS_ASSUME_NONNULL_END
