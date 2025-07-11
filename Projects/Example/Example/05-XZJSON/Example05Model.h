//
//  Example05Model.h
//  Example
//
//  Created by Xezun on 2024/10/12.
//

#import <UIKit/UIKit.h>
@import XZKit;
@import YYModel;

NS_ASSUME_NONNULL_BEGIN

@class Example05Model, Example05Teacher;

@interface Example05Response : NSObject
@property (nonatomic, strong) Example05Model *model;
@property (nonatomic, strong) NSArray *teachers;
@end

typedef struct Example05Struct {
    int a;
    float b;
    double c;
} Example05Struct;

typedef union Example05Union {
    int intValue;
    float floatValue;
} Example05Union;

@interface Example05Model : NSObject <XZJSONCoding>

// 基本数据类型
@property (nonatomic) char charValue;
@property (nonatomic) unsigned char unsignedCharValue;
@property (nonatomic) int intValue;
@property (nonatomic) unsigned int unsignedIntValue;
@property (nonatomic) short shortValue;
@property (nonatomic) unsigned short unsignedShortValue;
@property (nonatomic) long longValue;
@property (nonatomic) unsigned long unsignedLongValue;
@property (nonatomic) long long longLongValue;
@property (nonatomic) unsigned long long unsignedLongLongValue;
@property (nonatomic) float floatValue;
@property (nonatomic) double doubleValue;
@property (nonatomic) long double longDoubleValue;
@property (nonatomic) BOOL boolValue;

@property (nonatomic) const char *cStringValue;
@property (nonatomic) int *cArrayValue;

// 指针类型
@property (nonatomic) void *pointerValue;

// 结构体类型
@property (nonatomic) Example05Struct structValue;

@property (nonatomic) CGRect rectStructValue;
@property (nonatomic) CGSize sizeStructValue;
@property (nonatomic) CGPoint pointStructValue;
@property (nonatomic) UIEdgeInsets edgeInsetsStructValue;
@property (nonatomic) CGVector vectorStructValue;
@property (nonatomic) CGAffineTransform affineTransformStructValue;
@property (nonatomic) NSDirectionalEdgeInsets directionalEdgeInsetsStructValue;
@property (nonatomic) UIOffset offsetStructValue;

// 联合体类型
@property (nonatomic) Example05Union unionValue;

// 类类型
@property (nonatomic) Class classValue;

// 选择子类型
@property (nonatomic) SEL selectorValue;

// 字符串类型
@property (nonatomic, copy) NSString *stringValue;
@property (nonatomic, copy) NSMutableString *mutableStringValue;

@property (nonatomic) NSValue *numberValueValue;
@property (nonatomic) NSValue *structValueValue; // CGRect

@property (nonatomic) NSNumber *numberValue;
@property (nonatomic) NSDecimalNumber *decimalNumberValue;
@property (nonatomic) NSData *dataValue;
@property (nonatomic) NSMutableData *mutableDataValue;

@property (nonatomic) NSData *hexDataValue;
@property (nonatomic) NSData *hexMutableDataValue;

@property (nonatomic) NSDate *date1Value;
@property (nonatomic) NSDate *date2Value;
@property (nonatomic) NSDate *date3Value;
@property (nonatomic) NSURL *urlValue;
// 数组类型
@property (nonatomic, strong) NSArray *arrayValue;
@property (nonatomic, strong) NSMutableArray *mutableArrayValue;
// 对象类型
@property (nonatomic, strong) NSDictionary *dictionaryValue;
@property (nonatomic, strong) NSMutableDictionary *mutableDictionaryValue;

@property (nonatomic, strong) NSMutableSet *mutableSetValue;
@property (nonatomic, strong) NSSet *setValue;
@property (nonatomic, strong) NSCountedSet *countedSetValue;

@property (nonatomic, strong) NSMutableOrderedSet *mutableOrderedSetValue;
@property (nonatomic, strong) NSOrderedSet *orderedSetValue;

@property (nonatomic, copy) NSString *keyPathValue;
@property (nonatomic, copy) NSString *keyArrayValue;

@property (nonatomic, strong) Example05Model *objectValue;

@end

@interface Example05Human : NSObject <XZJSONCoding, NSSecureCoding>
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger age;
@end

@class Example05Student;
@interface Example05Teacher : Example05Human <XZJSONCoding>
@property (nonatomic, copy) NSArray<Example05Student *> *students;
@property (nonatomic, copy) NSString *school;
@property (nonatomic) char *foo;
@end

@interface Example05Student : Example05Human <XZJSONCoding>
@property (nonatomic, weak) Example05Teacher *teacher;
@property (nonatomic) CGRect frame; // 使用 CGRect 属性，在 i386 模拟器中，无法通过 objc_msgSend 访问属性？
@property (nonatomic) Example05Struct bar;
@end

NS_ASSUME_NONNULL_END

#import "Example05XZWeiboModel.h"
#import "Example05YYWeiboModel.h"
#import "Example05XZGHUser.h"
#import "Example05YYGHUser.h"
