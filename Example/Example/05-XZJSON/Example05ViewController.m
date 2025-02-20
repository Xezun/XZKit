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
    NSLog(@"JSON 数据：%@", _data);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    NSLog(@"%@", [XZObjcClassDescriptor descriptorForClass:[Example05Model class]]);
                    break;
                case 1:
                    NSLog(@"%@", [XZObjcClassDescriptor descriptorForClass:[Example05Human class]]);
                    break;
                case 2:
                    NSLog(@"%@", [XZObjcClassDescriptor descriptorForClass:[Example05Teacher class]]);
                    break;
                case 3:
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
                    _model = [XZJSON decode:_data options:(NSJSONReadingAllowFragments) class:[Example05Teacher class]];
                    NSLog(@"%@", _model);
                    break;
                }
                case 1: {
                    NSData *json = [XZJSON encode:_model options:NSJSONWritingPrettyPrinted error:nil];
                    NSLog(@"%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
                    break;
                }
                case 2: {
                    NSAssert([_model isKindOfClass:[Example05Teacher class]], @"");
                    NSAssert([_model.name isEqualToString:@"Smith"], @"");
                    NSAssert(_model.age == 50, @"");
                    NSAssert(_model.students.count == 3, @"");
                    
                    for (Example05Student *student in _model.students) {
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
                    }
                    
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
            switch (indexPath.row) {
                case 0: {
                    NSError *error = nil;
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_model requiringSecureCoding:[[_model class] supportsSecureCoding] error:&error];
                    if (error) {
                        NSLog(@"归档失败：%@", error);
                    }
                    NSLog(@"%@", data);
                    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"model.plist"];
                    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
                        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
                    }
                    [data writeToFile:path atomically:NO];
                    NSLog(@"%@", path);
                    break;
                }
                case 1: {
                    NSString *path = [NSString stringWithFormat:@"%@/model.plist", NSTemporaryDirectory()];
                    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
                        XZToast *toast = [XZToast messageToast:@"归档不存在"];
                        [self showToast:toast duration:3.0 offset:CGPointZero completion:nil];
                        return;
                    }
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    NSError *error = nil;
                    Example05Teacher *model = [NSKeyedUnarchiver unarchivedObjectOfClass:[Example05Teacher class] fromData:data error:&error];
                    if (error) {
                        NSLog(@"解档失败：%@", error);
                    }
                    NSLog(@"%@", model);
                    data = [XZJSON encode:model options:NSJSONWritingPrettyPrinted error:nil];
                    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    break;
                }
                case 2: {
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


