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
@import XZDefines;
@import XZExtensions;

@interface Example05ViewController () {
    NSString *_JSONString;
    Example05Response *_response;
    NSArray<Example05Teacher *> *_teachers;
}

@end

@implementation Example05ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"Example05Model" withExtension:@"json"];
    _JSONString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    _response = [XZJSON decode:_JSONString options:kNilOptions class:[Example05Response class]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = nil;
    switch (indexPath.section) {
        case 0: {
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    text = _JSONString;
                    break;
                }
                case 1: {
                    text = [[XZObjcClassDescriptor descriptorWithClass:[Example05Model class]] description];
                    break;
                }
                case 2: {
                    Example05Model *model = _response.model;
                    NSAssert(model.charValue == 'A', @"");
                    NSAssert(model.unsignedCharValue == 65, @"");
                    NSAssert(model.intValue == 123, @"");
                    NSAssert(model.unsignedIntValue == 456, @"");
                    NSAssert(model.shortValue == 78, @"");
                    NSAssert(model.unsignedShortValue == 90, @"");
                    NSAssert(model.longValue == 123456, @"");
                    NSAssert(model.unsignedLongValue == 654321, @"");
                    NSAssert(model.longLongValue == 1234567890, @"");
                    NSAssert(model.unsignedLongLongValue == 9876543210, @"");
                    NSAssert(model.floatValue == (float)123.45, @"");
                    NSAssert(model.doubleValue == (double)678.90, @"");
                    NSAssert(model.longDoubleValue == (long double)1234567890.123456, @"");
                    NSAssert(model.boolValue == true, @"");
                    
                    NSAssert(strcmp(model.cStringValue, "C String") == 0, @"");
                    NSAssert(model.cArrayValue[0] == 1, @"");
                    NSAssert(model.cArrayValue[1] == 2, @"");
                    NSAssert(model.cArrayValue[2] == 3, @"");
                    NSAssert(model.pointerValue == (__bridge void *)model, @"");
                    
                    NSAssert(model.structValue.a == 10, @"");
                    NSAssert(model.structValue.b == (float)0.12, @"");
                    NSAssert(model.structValue.c == (double)3.14159265, @"");
                    
                    NSAssert(CGRectEqualToRect(model.rectStructValue, CGRectMake(10, 20, 30, 40)), @"");
                    NSAssert(CGSizeEqualToSize(model.sizeStructValue, CGSizeMake(10, 20)), @"");
                    NSAssert(CGPointEqualToPoint(model.pointStructValue, CGPointMake(30, 40)), @"");
                    NSAssert(UIEdgeInsetsEqualToEdgeInsets(model.edgeInsetsStructValue, UIEdgeInsetsMake(10, 20, 30, 40)), @"");
                    NSAssert(model.vectorStructValue.dx == 10 && model.vectorStructValue.dy == 20, @"");
                    NSAssert(CGAffineTransformEqualToTransform(model.affineTransformStructValue, CGAffineTransformMake(10, 20, 30, 40, 50, 60)), @"");
                    NSAssert(NSDirectionalEdgeInsetsEqualToDirectionalEdgeInsets(model.directionalEdgeInsetsStructValue, NSDirectionalEdgeInsetsMake(10, 20, 30, 40)), @"");
                    NSAssert(UIOffsetEqualToOffset(model.offsetStructValue, UIOffsetMake(10, 20)), @"");
                    
                    NSAssert(model.unionValue.intValue == 1234, @"");
                    
                    NSAssert(model.classValue == NSObject.class, @"");
                    NSAssert(model.selectorValue == @selector(viewDidLoad), @"");
                    
                    NSAssert([model.stringValue isKindOfClass:NSString.class], @"");
                    NSAssert([model.stringValue isEqualToString:@"NSString Value"], @"");
                    
                    NSAssert([model.mutableStringValue isKindOfClass:NSMutableString.class], @"");
                    NSAssert([model.mutableStringValue isEqualToString:@"NSMutableString Value"], @"");
                    
                    NSAssert([model.numberValueValue isKindOfClass:NSValue.class], @"");
                    NSInteger numberValueValue = 0;
                    [model.numberValueValue getValue:&numberValueValue size:sizeof(NSInteger)];
                    NSAssert(numberValueValue == 1231122, @"");
                    
                    NSAssert([model.structValueValue isKindOfClass:NSValue.class], @"");
                    CGRect structValueValue;
                    [model.structValueValue getValue:&structValueValue size:sizeof(CGRect)];
                    NSAssert(CGRectEqualToRect(structValueValue, CGRectMake(10, 20, 30, 40)), @"");
                    
                    NSAssert([model.numberValue isKindOfClass:NSNumber.class], @"");
                    NSAssert(model.numberValue.integerValue == 123, @"");
                    
                    NSAssert([model.decimalNumberValue isKindOfClass:NSDecimalNumber.class], @"");
                    NSAssert([model.decimalNumberValue isEqualToValue:[NSDecimalNumber decimalNumberWithString:@"123.45"]], @"");
                    
                    NSAssert([model.dataValue isKindOfClass:NSData.class], @"");
                    NSString *dataValue = [model.dataValue base64EncodedStringWithOptions:kNilOptions];
                    NSAssert([dataValue isEqualToString:@"SGVsbG8gV29ybGQ="], @"");
                    
                    NSAssert([model.mutableDataValue isKindOfClass:NSMutableData.class], @"");
                    NSString *mutableDataValue = [model.mutableDataValue base64EncodedStringWithOptions:kNilOptions];
                    NSAssert([mutableDataValue isEqualToString:@"SGVsbG8gV29ybGQ="], @"");
                    
                    NSAssert([model.hexDataValue isKindOfClass:NSData.class], @"");
                    NSString *hexDataValue = [model.hexDataValue xz_hexEncodedString];
                    NSAssert([hexDataValue isEqualToString:@"585a4b6974"], @"");
                    
                    NSAssert([model.hexMutableDataValue isKindOfClass:NSMutableData.class], @"");
                    NSString *hexMutableDataValue = [model.hexMutableDataValue xz_hexEncodedString];
                    NSAssert([hexMutableDataValue isEqualToString:@"585a4b6974"], @"");
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy-MM-dd";
                    NSAssert([[formatter stringFromDate:model.date1Value] isEqualToString:@"2023-10-01"], @"");
                    formatter.dateFormat = @"hh:mm:ss";
                    NSAssert([[formatter stringFromDate:model.date2Value] isEqualToString:@"12:34:56"], @"");
                    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
                    NSAssert([[formatter stringFromDate:model.date3Value] isEqualToString:@"2023-10-01 12:34:56"], @"");
                    
                    NSAssert([model.urlValue isKindOfClass:NSURL.class], @"");
                    NSAssert([model.urlValue.absoluteString isEqualToString:@"https://example.com"], @"");
                    
                    NSAssert([model.arrayValue isKindOfClass:NSArray.class], @"");
                    NSAssert([model.arrayValue[0] isEqualToString:@"a"], @"");
                    NSAssert([model.arrayValue[1] isEqualToString:@"b"], @"");
                    NSAssert([model.arrayValue[2] isEqualToString:@"c"], @"");
                    
                    NSAssert([model.mutableArrayValue isKindOfClass:NSArray.class], @"");
                    NSAssert([model.mutableArrayValue[0] isEqualToString:@"x"], @"");
                    NSAssert([model.mutableArrayValue[1] isEqualToString:@"y"], @"");
                    NSAssert([model.mutableArrayValue[2] isEqualToString:@"z"], @"");
                    
                    NSAssert([model.dictionaryValue isKindOfClass:NSDictionary.class], @"");
                    NSAssert([model.dictionaryValue[@"key1"] isEqualToString:@"value1"], @"");
                    NSAssert([model.dictionaryValue[@"key2"] isEqualToString:@"value2"], @"");
                    
                    NSAssert([model.mutableDictionaryValue isKindOfClass:NSMutableDictionary.class], @"");
                    NSAssert([model.mutableDictionaryValue[@"keyA"] isEqualToString:@"valueA"], @"");
                    NSAssert([model.mutableDictionaryValue[@"keyB"] isEqualToString:@"valueB"], @"");
                    
                    NSAssert([model.setValue isKindOfClass:NSSet.class], @"");
                    NSAssert([model.setValue containsObject:@"set1"], @"");
                    NSAssert([model.setValue containsObject:@"set2"], @"");
                    
                    NSAssert([model.mutableSetValue isKindOfClass:NSMutableSet.class], @"");
                    NSAssert([model.mutableSetValue containsObject:@"mset1"], @"");
                    NSAssert([model.mutableSetValue containsObject:@"mset2"], @"");
                    
                    NSAssert([model.countedSetValue isKindOfClass:NSCountedSet.class], @"");
                    NSAssert([model.countedSetValue containsObject:@"cset1"], @"");
                    NSAssert([model.countedSetValue containsObject:@"cset2"], @"");
                    
                    NSAssert([model.orderedSetValue isKindOfClass:NSOrderedSet.class], @"");
                    NSAssert([model.orderedSetValue containsObject:@"ord1"], @"");
                    NSAssert([model.orderedSetValue containsObject:@"ord2"], @"");
                    
                    NSAssert([model.mutableOrderedSetValue isKindOfClass:NSMutableOrderedSet.class], @"");
                    NSAssert([model.mutableOrderedSetValue containsObject:@"mord1"], @"");
                    NSAssert([model.mutableOrderedSetValue containsObject:@"mord2"], @"");
                    
                    NSAssert([model.keyPathValue isEqualToString:@"123"], @"");
                    NSAssert([model.keyArrayValue isEqualToString:@"456"], @"");
                    
                    Example05Model *objectValue = model.objectValue;
                    NSAssert([objectValue isKindOfClass:[Example05Model class]], @"");
                    NSAssert(objectValue.charValue == 'B', @"");
                    NSAssert(objectValue.intValue == 456, @"");
                    NSAssert([objectValue.keyArrayValue isEqualToString:@"456"], @"");
                    
                    NSData *data = [XZJSON encode:model options:NSJSONWritingPrettyPrinted error:nil];
                    text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    text = [[XZObjcClassDescriptor descriptorWithClass:[Example05Human class]] description];
                    break;
                }
                case 1: {
                    text = [[XZObjcClassDescriptor descriptorWithClass:[Example05Teacher class]] description];
                    break;
                }
                case 2: {
                    text = [[XZObjcClassDescriptor descriptorWithClass:[Example05Student class]] description];
                    break;
                }
                case 3: {
                    _teachers = [XZJSON decode:_response.teachers options:(NSJSONReadingAllowFragments) class:[Example05Teacher class]];
                    text = [XZJSON model:_teachers description:0];
                    break;
                }
                case 4: {
                    if (!_teachers) {
                        [self xz_showToast:[XZToast messageToast:@"请先点击“数据 => 模型”"] duration:3.0 completion:nil];
                        return;
                    }
                    NSData *json = [XZJSON encode:_teachers options:NSJSONWritingPrettyPrinted error:nil];
                    text = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                    break;
                }
                
                default: {
                    break;
                }
            }
            break;
        }
        case 3: {
            switch (indexPath.row) {
                case 0: {
                    if (!_teachers) {
                        [self xz_showToast:[XZToast messageToast:@"请先点击“数据 => 模型”"] completion:nil];
                        return;
                    }
                    NSError *error = nil;
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_teachers requiringSecureCoding:[[_teachers class] supportsSecureCoding] error:&error];
                    if (error) {
                        XZLog(@"归档失败：%@", error);
                        [self xz_showToast:[XZToast messageToast:@"归档失败"] completion:nil];
                        return;
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
                        [self xz_showToast:toast completion:nil];
                        return;
                    }
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    NSError *error = nil;
                    NSSet *set = [NSSet setWithObjects:[Example05Teacher class], [NSArray class], nil];
                    NSArray *teachers = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:&error];
                    if (error) {
                        XZLog(@"解档失败：%@", error);
                        [self xz_showToast:[XZToast messageToast:@"解档失败"] completion:nil];
                        return;
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
        XZLog(@"%@", text);
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


