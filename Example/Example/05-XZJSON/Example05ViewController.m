//
//  Example05ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example05ViewController.h"
#import "Example05Model.h"

@import XZObjcDescriptor;
@import XZToast;

@interface Example05ViewController ()

@end

@implementation Example05ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    NSLog(@"%@", [XZObjcClassDescriptor descriptorForClass:[Example05Model class]]);
                    NSLog(@"%@", [XZObjcClassDescriptor descriptorForClass:[Example05Human class]]);
                    NSLog(@"%@", [XZObjcClassDescriptor descriptorForClass:[Example05Teacher class]]);
                    NSLog(@"%@", [XZObjcClassDescriptor descriptorForClass:[Example05Student class]]);
                    break;
                    
                default:
                    break;
            }
            break;
        }
        case 1: {
            Example05Teacher *teacher = nil;
            {
                NSURL *url = [NSBundle.mainBundle URLForResource:@"Example05Model" withExtension:@"json"];
                NSData *data = [NSData dataWithContentsOfURL:url];
                teacher = [XZJSON decode:data options:(NSJSONReadingAllowFragments) class:[Example05Teacher class]];
            }
            
            NSLog(@"%@", NSStringFromCGRect(teacher.students.firstObject.frame));
            
            switch (indexPath.row) {
                case 0: {
                    NSLog(@"%@", [XZJSON modelDescription:teacher]);
                    NSAssert([teacher isKindOfClass:[Example05Teacher class]], @"");
                    [teacher description];
                    break;
                }
                case 1: {
                    NSData *json = [XZJSON encode:teacher options:NSJSONWritingPrettyPrinted error:nil];
                    NSLog(@"%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
                    break;
                }
                case 2: {
                    NSAssert([teacher.name isEqualToString:@"Smith"], @"");
                    NSAssert(teacher.age == 50, @"");
                    NSAssert(teacher.students.count == 3, @"");
                    
                    [teacher.students enumerateObjectsUsingBlock:^(Example05Student * _Nonnull student, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSAssert([student isKindOfClass:[Example05Student class]], @"");
                        NSAssert([student.teacher isKindOfClass:[Example05Teacher class]], @"");
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
                    
                    XZToast *toast = [XZToast messageToast:@"校验成功"];
                    [self showToast:toast duration:3.0 offset:CGPointZero completion:nil];
                    break;
                }
                default: {
                    break;
                }
            }
            break;
        }
        default: {
            
            break;
        }
    }
}

@end


