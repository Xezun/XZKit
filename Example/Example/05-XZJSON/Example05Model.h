//
//  Example05Model.h
//  Example
//
//  Created by Xezun on 2024/10/12.
//

#import <Foundation/Foundation.h>
@import XZJSON;

NS_ASSUME_NONNULL_BEGIN

@interface Example05Model : NSObject
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

typedef struct Example05Struct {
    int a;
    float b;
    double c;
} Example05Struct;

@interface Example05Student : Example05Human <XZJSONCoding>
@property (nonatomic, weak) Example05Teacher *teacher;
@property (nonatomic) CGRect frame; // 使用 CGRect 属性，在 i386 模拟器中，无法通过 objc_msgSend 访问属性？
@property (nonatomic) Example05Struct bar;
@end

NS_ASSUME_NONNULL_END
