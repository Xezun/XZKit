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
/// - 模型转换依赖于 setter 方法，所以只读属性会被忽略。
/// - 通用逻辑无法处理弱引用关系，所以值为对象的 `unsafe_unretained` 或 `assign` 修饰的属性会被忽略。
///
/// 关于 NSData 类型的属性。
/// - 字符串将会转化 UTF8 二进制流赋值给 NSData 类型的属性。
/// - 符合 URL Data 的字符串，仅支持 base64 一种编码方式。
@interface XZJSON : NSObject
/// 日期转换所使用的格式，默认 `yyyy-MM-dd HH:mm:ss` 格式。
///
/// 一般情况下，数据模型化在子线程中处理，因此在业务中，仅应在程序初始化（模型转换开始前）时，调整默认的日期格式。
///
/// 非默认日期格式的模型，可以通过`XZJSONDecoding`或`XZJSONEncoding`协议自定日期转换。
@property (class, nonatomic, readonly) NSDateFormatter *dateFormatter;
@end

@interface XZJSON (XZJSONDecoding)
/// JSON 数据模型化。
///
/// JSON 数据包括 JSON 字符串 NSString 数据，或 JSON 二进制 NSData 数据，或者二者组成的数组。
///
/// - Parameters:
///   - json: JSON 数据
///   - options: JSON 读取选项，如果 JSON 已解析，则此参数忽略
///   - class: 模型的类对象
+ (nullable id)decode:(nullable id)json options:(NSJSONReadingOptions)options class:(Class)aClass;

/// 使用指定模型实例 model 将 JSON 数据字典模型化。
/// - Parameters:
///   - model: 模型实例对象
///   - dictionary: JSON 数据字典
+ (void)model:(id)model decodeFromDictionary:(NSDictionary *)dictionary;
@end

@interface XZJSON (XZJSONEncoding)
/// 模型实例 JSON 数据化。
/// - Parameters:
///   - object: 模型对象
///   - options: JSON 生成选项
///   - error: 错误输出
+ (nullable NSData *)encode:(nullable id)object options:(NSJSONWritingOptions)options error:(NSError **)error;

/// 将模型实例 model 数据化为指定 JSON 数据字典。
/// - Parameters:
///   - model: 模型实例对象
///   - dictionary: 数据字典
+ (void)model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary;
@end

@interface XZJSON (NSCoding)

/// 辅助模型归档的方法。
/// ```objc
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
/// ```objc
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

@interface XZJSON (NSCopying)
/// 模型复制。
/// - Parameter model: 被模型的模型对象
+ (id)modelCopy:(id)model;
@end

@interface XZJSON (NSDescription)
/// 模型描述。
/// - Parameter model: 待描述的模型对象
+ (NSString *)modelDescription:(id)model;
@end

@interface XZJSON (NSHashable)
/// 模型哈希。
/// - Parameter model: 待哈希的模型对象
+ (NSUInteger)modelHash:(id)model;
@end

@interface XZJSON (NSEquatable)
/// 模型比较。
/// - Parameters:
///   - model1: 待比较的模型
///   - model2: 被比较的模型
+ (BOOL)model:(id)model1 isEqualToModel:(id)model2;
@end

NS_ASSUME_NONNULL_END
