//
//  XZJSON.h
//  XZJSON
//
//  Created by Xezun on 2024/9/28.
//

#import <Foundation/Foundation.h>
#import "XZJSONDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 支持模型对象与 JSON 数据互相转换的工具类。
///
/// 关于模型属性。
/// - 模型转换依赖于 `setter` 方法，所以只读属性会被忽略。
/// - 通用逻辑无法处理弱引用关系，所以 `unsafe_unretained` 或 `assign` 修饰的对象的属性会被忽略。
///
/// 默认无法处理的属性，或支持多种形式的属性，比如 NSData、NSDate 等，可通过实现 `XZJSONCoding` 协议自定义转换过程。
///
/// - `-JSONDecodeValue:forKey:`
/// - `-JSONEncodeValueForKey:`
///
/// 注：上述方法也会同时应用于 NSCoding 归档/解档。
///
/// XZJSON 为符合以下格式的 NSData、NSDate、NSValue 的类型，提供了默认转换方法，以简化模型的处理。
///
/// - NSValue: number 或 { "type": NSValue.objcType, "data": base64 } 字典。
/// - NSDate: timestamp （秒）或 `yyyy-MM-dd HH:mm:ss` 格式。
/// - NSData: base64 字符串。
///
/// 另外，大部分结构体、共用体、C 指针等类型，由于涉及内存大小或内存管理，转换过程是不可预知的，只能自定义转换过程，幸好的是开发中，并不常用这些类型。
@interface XZJSON : NSObject
/// “字符串-日期”转换的默认格式化工具，默认 `yyyy-MM-dd HH:mm:ss` 格式。
///
/// 建议在业务中，使用统一的日期格式，这样在程序初始化时，模型转换开始前，通过此属性设置默认日期格式，即可避免在每个模型中重复处理。
///
/// > 由于数据处理一般在子线程，这意味着，在使用时，动态修改日期格式，可能会有意外风险。
///
/// 另外，非默认的日期格式的模型，可以通过`XZJSONCoding`协议自定日期转换过程。
///
/// > 数值数据，默认当作时间戳（秒）转换为日期，即 JSON 数据为 number 且目标属性为 NSDate 类型。
@property (class, nonatomic, readonly) NSDateFormatter *dateFormatter;
@end

@interface XZJSON (XZJSONDecoding)
/// JSON 数据模型化。
///
/// - NSValue 支持 number 和 { "type": NSValue.objcType, "data": base64 } 两种数据格式
/// - NSData 支持 base64 和 { "type": "base64", "data": base64 } 两种格式
/// - NSDate 支持 timestamp （秒）和 "yyyy-MM-dd hh:mm:ss" 两种格式
/// - 有 `NSStringFrom` 原生函数的结构体。
/// - 属性为字典，但 JSON 数据为数组，自动将数组转为以 index 为键的字典。
/// - 属性为数组，但 JSON 数据为字典，自动将字典转转为以字典为元素的数组。
///
/// 关于 JSON 数据：NSString 类型 JSON 字符串，或 NSData 类型 JSON 二进制流，或前二者组成的数组。
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

@interface XZJSON (XZJSONEncoding)
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

typedef NS_ENUM(NSUInteger, XZJSONEquation) {
    /// 不相等
    XZJSONEquationNo NS_SWIFT_NAME(False) = -1,
    /// 未知，未比较
    XZJSONEquationUnknown NS_SWIFT_NAME(Unknown) = 0,
    /// 相等
    XZJSONEquationYes NS_SWIFT_NAME(True) = 1,
};

@interface XZJSON (NSEquatable)

/// 模型比较。如果模型的属性相同，则认为模型相等，即使模型的类型不同。
/// - Parameters:
///   - model1: 待比较的模型
///   - model2: 被比较的模型
///   - block: 如果属性值无法比较，将调用此块函数，如不提供，则认为属性不相等。
+ (BOOL)model:(id)model1 isEqualToModel:(id)model2 comparator:(XZJSONEquation (^_Nullable)(id model1, id model2, NSString *key))block;

@end

NS_ASSUME_NONNULL_END
