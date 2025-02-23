//
//  Example05ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example05ViewController.h"
#import "Example05Model.h"
#import "Example05TextViewController.h"

@import XZObjcDescriptor;
@import XZToast;

@interface Example05ViewController () {
    NSString *_data;
    NSArray<Example05Teacher *> *_teachers;
}

@end

@implementation Example05ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"Example05Model" withExtension:@"json"];
    _data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = nil;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    text = [[XZObjcClassDescriptor descriptorForClass:[Example05Model class]] description];
                    break;
                case 1:
                    text = [[XZObjcClassDescriptor descriptorForClass:[Example05Human class]] description];
                    break;
                case 2:
                    text = [[XZObjcClassDescriptor descriptorForClass:[Example05Teacher class]] description];
                    break;
                case 3:
                    text = [[XZObjcClassDescriptor descriptorForClass:[Example05Student class]] description];
                    break;
                default:
                    break;
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    text = _data;
                    break;
                }
                case 1: {
                    _teachers = [XZJSON decode:_data options:(NSJSONReadingAllowFragments) class:[Example05Teacher class]];
                    text = [XZJSON model:_teachers description:0];
                    break;
                }
                case 2: {
                    if (!_teachers) {
                        [self showToast:[XZToast messageToast:@"请先点击“数据 => 模型”"] duration:3.0 offset:CGPointZero completion:nil];
                        return;
                    }
                    NSData *json = [XZJSON encode:_teachers options:NSJSONWritingPrettyPrinted error:nil];
                    text = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                    break;
                }
                case 3: {
//                    if (!_teachers) {
//                        [self showToast:[XZToast messageToast:@"请先点击“数据 => 模型”"] duration:3.0 offset:CGPointZero completion:nil];
//                        return;
//                    }
//                    NSAssert([_teachers isKindOfClass:[Example05Teacher class]], @"");
//                    NSAssert([_teachers.name isEqualToString:@"Smith"], @"");
//                    NSAssert(_teachers.age == 50, @"");
//                    NSAssert(_teachers.students.count == 3, @"");
//                    
//                    for (Example05Student *student in _teachers.students) {
//                        NSAssert([student isKindOfClass:[Example05Student class]], @"");
//                        NSAssert([student.teacher isKindOfClass:[Example05Teacher class]], @"");
//                        if ([student.name isEqualToString:@"Peter"]) {
//                            NSAssert(student.age == 12, @"");
//                        } else if ([student.name isEqualToString:@"Jim"]) {
//                            NSAssert(student.age == 13, @"");
//                        } else if ([student.name isEqualToString:@"Lily"]) {
//                            NSAssert(student.age == 11, @"");
//                        } else {
//                            NSAssert(NO, @"teacher.students 校验失败");
//                        }
//                    }
//                    
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
                    if (!_teachers) {
                        [self showToast:[XZToast messageToast:@"请先点击“数据 => 模型”"] duration:3.0 offset:CGPointZero completion:nil];
                        return;
                    }
                    NSError *error = nil;
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_teachers requiringSecureCoding:[[_teachers class] supportsSecureCoding] error:&error];
                    if (error) {
                        NSLog(@"归档失败：%@", error);
                        return [self showToast:[XZToast messageToast:@"归档失败"] duration:3.0 offset:CGPointZero completion:nil];
                    }
                    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"model.plist"];
                    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
                        [NSFileManager.defaultManager removeItemAtPath:path error:&error];
                    }
                    [data writeToFile:path atomically:NO];
                    text = [[NSDictionary dictionaryWithContentsOfFile:path] description];
                    break;
                }
                case 1: {
                    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"model.plist"];
                    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
                        XZToast *toast = [XZToast messageToast:@"归档不存在"];
                        [self showToast:toast duration:3.0 offset:CGPointZero completion:nil];
                        return;
                    }
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    NSError *error = nil;
                    NSSet *set = [NSSet setWithObjects:[Example05Teacher class], [NSArray class], nil];
                    NSArray *teachers = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:&error];
                    if (error) {
                        NSLog(@"解档失败：%@", error);
                        return [self showToast:[XZToast messageToast:@"解档失败"] duration:3.0 offset:CGPointZero completion:nil];
                    }
                    text = [XZJSON model:teachers description:0];
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
    
    if (text) {
        [self performSegueWithIdentifier:@"text" sender:text];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Example05TextViewController *nextVC = segue.destinationViewController;
    if ([nextVC isKindOfClass:[Example05TextViewController class]]) {
        nextVC.text = sender;
    }
}

@end


