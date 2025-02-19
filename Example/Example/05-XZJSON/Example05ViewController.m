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

@interface Example05ViewController () {
    NSString *_data;
    Example05Teacher *_model;
}

@end

@implementation Example05ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"Example05Model" withExtension:@"json"];
    _data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    _model = [XZJSON decode:_data options:(NSJSONReadingAllowFragments) class:[Example05Teacher class]];
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
            switch (indexPath.row) {
                case 0: {
                    NSLog(@"%@", [XZJSON modelDescription:_model]);
                    NSAssert([_model isKindOfClass:[Example05Teacher class]], @"");
                    break;
                }
                case 1: {
                    NSData *json = [XZJSON encode:_model options:NSJSONWritingPrettyPrinted error:nil];
                    NSLog(@"%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
                    break;
                }
                case 2: {
                    NSAssert([_model.name isEqualToString:@"Smith"], @"");
                    NSAssert(_model.age == 50, @"");
                    NSAssert(_model.students.count == 3, @"");
                    
                    [_model.students enumerateObjectsUsingBlock:^(Example05Student * _Nonnull student, NSUInteger idx, BOOL * _Nonnull stop) {
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
        case 2: {
            NSError *error = nil;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_model requiringSecureCoding:[[_model class] supportsSecureCoding] error:&error];
            switch (indexPath.row) {
                case 0: {
                    if (error) {
                        NSLog(@"归档失败：%@", error);
                    }
                    NSLog(@"归档数据：%@", data);
                    break;
                }
                case 1: {
                    NSError *error = nil;
                    Example05Teacher *model = [NSKeyedUnarchiver unarchivedObjectOfClass:[Example05Teacher class] fromData:data error:&error];
                    if (error) {
                        NSLog(@"解档失败：%@", error);
                    }
                    NSLog(@"%@", [model description]);
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default: {
            
            break;
        }
    }
}

@end


