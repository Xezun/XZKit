//
//  Example05ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example05ViewController.h"
#import "Example05TestModels.h"

@interface Example05ViewController ()
@end

@implementation Example05ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"Example05" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    Example05TestTeacher *teacher = [XZJSON decode:data options:(NSJSONReadingAllowFragments) class:[Example05TestTeacher class]];
    
    NSAssert([teacher isKindOfClass:[Example05TestTeacher class]], @"");
    NSAssert([teacher.name isEqualToString:@"Smith"], @"");
    NSAssert(teacher.age == 50, @"");
    NSAssert(teacher.students.count == 3, @"");
    
    [teacher.students enumerateObjectsUsingBlock:^(Example05TestStudent * _Nonnull student, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([student isKindOfClass:[Example05TestStudent class]], @"");
        NSAssert([student.teacher isKindOfClass:[Example05TestTeacher class]], @"");
        if ([student.name isEqualToString:@"Peter"]) {
            NSAssert(student.age == 20, @"");
        } else if ([student.name isEqualToString:@"Jim"]) {
            NSAssert(student.age == 21, @"");
        } else if ([student.name isEqualToString:@"Lily"]) {
            NSAssert(student.age == 19, @"");
        } else {
            NSAssert(NO, @"teacher.students 校验失败");
        }
    }];

    NSData *json = [XZJSON encode:teacher options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
}


@end


