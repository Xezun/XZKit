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

@interface Example05Human : NSObject <XZJSONCoding>
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger age;
@end

@class Example05Student;
@interface Example05Teacher : Example05Human <XZJSONCoding, XZJSONDecoding>
@property (nonatomic, copy) NSArray<Example05Student *> *students;
@property (nonatomic, copy) NSString *school;
@end

@interface Example05Student : Example05Human <XZJSONEncoding>
@property (nonatomic, unsafe_unretained) Example05Teacher *teacher;
@end

NS_ASSUME_NONNULL_END
