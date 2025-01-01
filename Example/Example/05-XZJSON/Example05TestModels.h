//
//  Example05TestModels.h
//  Example
//
//  Created by 徐臻 on 2024/10/12.
//

#import <Foundation/Foundation.h>
@import XZJSON;

NS_ASSUME_NONNULL_BEGIN

@interface Example05TestHuman : NSObject <XZJSONCoding>
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger age;
@end

@class Example05TestStudent;
@interface Example05TestTeacher : Example05TestHuman <XZJSONCoding, XZJSONDecoding>
@property (nonatomic, copy) NSArray<Example05TestStudent *> *students;
@property (nonatomic, copy) NSString *school;
@end

@interface Example05TestStudent : Example05TestHuman <XZJSONEncoding>
@property (nonatomic, weak) Example05TestTeacher *teacher;
@end

NS_ASSUME_NONNULL_END
