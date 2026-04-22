//
//  Example02ViewController.m
//  Example
//
//  Created by 徐臻 on 2026/4/24.
//

#import "Example02ViewController.h"
@import XZKit;

@interface Example02ViewController ()

@end

@implementation Example02ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *name = cell.textLabel.text;
    if ([name isEqualToString:@"CAAnimation"]) {
        CAAnimation *animation = [CAAnimation xz_vibrationAnimation];
        [cell.layer addAnimation:animation forKey:@"vibration"];
    } else if ([name isEqualToString:@"NSArray"]) {
        [self exampleNSArray];
        [self xz_showToast:[XZToast messageToast:@"请在控制台查看结果"]];
    } else if ([name isEqualToString:@"NSBundle"]) {
        NSString *buildVersion = NSBundle.mainBundle.xz_buildVersionString;
        NSString *shortVersion = NSBundle.mainBundle.xz_shortVersionString;
        NSString *executableName = NSBundle.mainBundle.xz_executableName;
        NSLog(@"应用名称：%@，发行版本：%@，构建版本：%@", executableName, shortVersion, buildVersion);
        [self xz_showToast:[XZToast messageToast:@"请在控制台查看结果"]];
    } else if ([name isEqualToString:@"NSObject"]) {
        [self exampleNSObject];
        [self xz_showToast:[XZToast messageToast:@"请在控制台查看结果"]];
    } else if ([name isEqualToString:@"NSString"]) {
        [self exampleToNumber];
        [self xz_showToast:[XZToast messageToast:@"请在控制台查看结果"]];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)exampleNSArray {
    {
        NSArray *array1 = @[@"0", @"1", @"2", @"3"];
        NSLog(@"问：数组 %@ 是否包含重复元素？", [NSString xz_stringWithJSONObject:array1]);
        NSLog(@"答：%@", array1.xz_containsEqualObjects ? @"是" : @"否");
        
        NSArray *array2 = @[@"0", @"1", @"2", @"3", @"1", @"2", @"3"];
        NSLog(@"问：数组 %@ 是否包含重复元素？", [NSString xz_stringWithJSONObject:array2]);
        NSLog(@"答：%@", array2.xz_containsEqualObjects ? @"是" : @"否");
    }
    
    {
        NSArray<NSNumber *> *array1 = @[@0, @1, @2, @3];
        NSLog(@"数组：%@", [NSString xz_stringWithJSONObject:array1]);
        NSLog(@"求和：%@", [array1 xz_reduce:@0 next:^id _Nullable(NSNumber *result, NSNumber * _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
            return @(obj.integerValue + result.integerValue);
        }]);
        
        NSArray *array2 = @[
            @[@"A", @"B", @"C"],
            @[@"1", @"2", @"3"]
        ];
        NSLog(@"数组：%@", [NSString xz_stringWithJSONObject:array2]);
        array2 = [array2 xz_reduce:[NSMutableArray new] next:^id _Nullable(NSMutableArray *result, NSArray * _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
            [result addObjectsFromArray:obj];
            return result;
        }];
        NSLog(@"降维：%@", [NSString xz_stringWithJSONObject:array2]);
    }
    
    {
        NSArray *array = @[@"A", @"B", @"C"];
        NSLog(@"数组：%@", [NSString xz_stringWithJSONObject:array]);
        NSLog(@"映射全部：%@", [NSString xz_stringWithJSONObject:[array xz_map:^id(id  _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
            return [NSString stringWithFormat:@"%ld => %@", idx, obj];
        }]]);
    }
    
    {
        NSArray *array = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9];
        NSLog(@"数组：%@", [NSString xz_stringWithJSONObject:array]);
        NSLog(@"映射偶数：%@", [NSString xz_stringWithJSONObject:[array xz_compactMap:^id _Nonnull(NSNumber *obj, NSInteger idx, BOOL * _Nonnull stop) {
            if (obj.integerValue % 2 == 0) {
                return [NSString stringWithFormat:@"%ld => %@", idx, obj];
            }
            return nil;
        }]]);
    }
    
    {
        NSArray *array = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9];
        NSLog(@"数组：%@", [NSString xz_stringWithJSONObject:array]);
        NSLog(@"筛选奇数：%@", [NSString xz_stringWithJSONObject:[array xz_filter:^BOOL(NSNumber *obj, NSInteger idx) {
            return obj.integerValue % 2 > 0;
        }]]);
    }
    
    {
        NSArray *array = @[
            @{ @"identifier": @"1", @"name": @"小明" },
            @{ @"identifier": @"2", @"name": @"小红" },
            @{ @"identifier": @"3", @"name": @"小刚" },
            @{ @"identifier": @"4", @"name": @"小白" },
        ];
        id object = nil;
        NSInteger index = 0;
        
        NSLog(@"数组：%@", [NSString xz_stringWithJSONObject:array]);
        
        object = [array xz_first:^BOOL(NSDictionary *obj, NSInteger idx) {
            NSString *identifier = obj[@"identifier"];
            return [identifier isEqualToString:@"2"];
        }];
        NSLog(@"正向查找元素[identifier=2]：%@", [NSString xz_stringWithJSONObject:object]);
        
        index = [array xz_firstIndex:^BOOL(NSDictionary *obj) {
            NSString *identifier = obj[@"identifier"];
            return [identifier isEqualToString:@"3"];
        }];
        NSLog(@"正向查找索引[identifier=3]：%ld", index);
        
        object = [array xz_last:^BOOL(NSDictionary *obj, NSInteger idx) {
            NSString *identifier = obj[@"identifier"];
            return [identifier isEqualToString:@"2"];
        }];
        NSLog(@"反向查找元素[identifier=2]：%@", [NSString xz_stringWithJSONObject:object]);
        
        index = [array xz_lastIndex:^BOOL(NSDictionary *obj) {
            NSString *identifier = obj[@"identifier"];
            return [identifier isEqualToString:@"3"];
        }];
        NSLog(@"反向查找索引[identifier=3]：%ld", index);
        
        BOOL contains = [array xz_contains:^BOOL(NSDictionary *obj, NSInteger idx) {
            NSString *name = obj[@"name"];
            return [name isEqualToString:@"小刚"];
        }];
        NSLog(@"查找是否包含[name=小刚]：%@", contains ? @"是" : @"否");
        
        contains = [array xz_contains:^BOOL(NSDictionary *obj, NSInteger idx) {
            NSString *name = obj[@"name"];
            return [name isEqualToString:@"张三"];
        }];
        NSLog(@"查找是否包含[name=张三]：%@", contains ? @"是" : @"否");
    }
    
    {
        NSArray *array1 = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
        NSArray *array2 = @[@"E", @"B", @"G", @"H", @"A", @"I", @"J"];
        NSLog(@"差异分析：%@ => %@", [NSString xz_stringWithJSONObject:array1], [NSString xz_stringWithJSONObject:array2]);
        NSMutableIndexSet   *inserts = [NSMutableIndexSet indexSet];
        NSMutableIndexSet   *deletes = [NSMutableIndexSet indexSet];
        NSMutableIndexSet   *remains = [NSMutableIndexSet indexSet];
        NSMutableDictionary *changes = [NSMutableDictionary dictionary];
        [array2 xz_differenceFromArray:array1 inserts:inserts deletes:deletes changes:changes remains:remains];
        
        NSLog(@"插入的元素：%@", [NSString xz_stringWithJSONObject:[inserts xz_map:^id _Nonnull(NSInteger idx, BOOL * _Nonnull stop) {
            return @(idx);
        }]]);
        
        NSLog(@"删除的元素：%@", [NSString xz_stringWithJSONObject:[deletes xz_map:^id _Nonnull(NSInteger idx, BOOL * _Nonnull stop) {
            return @(idx);
        }]]);
        
        NSLog(@"移动的元素：%@", [NSString xz_stringWithJSONObject:[changes xz_map:^id _Nonnull(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            return [NSString stringWithFormat:@"%@ => %@", obj, key];
        }]]);
        
        NSLog(@"未变的元素：%@", [NSString xz_stringWithJSONObject:[remains xz_map:^id _Nonnull(NSInteger idx, BOOL * _Nonnull stop) {
            return @(idx);
        }]]);
    }
    
}

- (void)exampleNSObject {
    NSObject *object = @[
        @{
            @"url": @"https://table1.com",
            @"sections": @[
                @{
                    @"url": @"https://section1.table1.com",
                    @"cells": @[
                        @{ @"url": @"https://cell_1.section1.table1.com" },
                        @{ @"url": @"https://cell_2.section1.table1.com" },
                        @{ @"url": @"https://cell_3.section1.table1.com" }
                    ]
                },
                @{
                    @"url": @"https://section2.table1.com",
                    @"cells": @[
                        @{ @"url": @"https://cell_1.section2.table1.com" },
                        @{ @"url": @"https://cell_2.section2.table1.com" },
                        @{ @"url": @"https://cell_3.section2.table1.com" }
                    ]
                }
            ]
        },
        @{
            @"url": @"https://table2.com",
            @"sections": @[
                @{
                    @"url": @"https://section1.table2.com",
                    @"cells": @[
                        @{ @"url": @"https://cell_1.section1.table2.com" },
                        @{ @"url": @"https://cell_2.section1.table2.com" },
                        @{ @"url": @"https://cell_3.section1.table2.com" }
                    ]
                },
                @{
                    @"url": @"https://section2.table2.com",
                    @"cells": @[
                        @{ @"url": @"https://cell_1.section2.table2.com" },
                        @{ @"url": @"https://cell_2.section2.table2.com" },
                        @{ @"url": @"https://cell_3.section2.table2.com" }
                    ]
                }
            ]
        }
    ];
    
    NSArray *keyPaths = @[
        @"url",
        @"sections.url",
        @"sections.cells.url"
    ];
    
    [object xz_enumerateValuesForKeyPaths:keyPaths usingBlock:^(id value, NSString *keyPath, BOOL *stop) {
        NSLog(@"%@ => %@", keyPath, value);
    }];
    
    NSArray *urls = [object xz_mapValuesForKeyPaths:keyPaths usingBlock:^id _Nullable(id  _Nullable value, NSString * _Nonnull keyPath, BOOL * _Nonnull stop) {
        return value;
    }];
    NSLog(@"urls: %@", [NSString xz_stringWithJSONObject:urls options:(NSJSONWritingPrettyPrinted)]);
}

- (void)testDate {
//    let dateString = "2025-09-09 09:10:20"
//    let date = Date.init(from: dateString, using: .dateTime)!
//    
//    #XZLog("日期字符串：\(dateString) => \(date)")
//    
//    let formats: [XZDateFormat] = [
//        .dateTime,   .shortDateTime,
//        .date,       .shortDate,
//        .monthDay,   .shortMonthDay,
//        .time,       .shortTime,
//        .hourMinute, .shortHourMinute
//    ]
//    
//    for format in formats {
//        let formatter = DateFormatter.init(format)
//        #XZLog("\(format) => \(date.formatted(using: formatter))");
//    }
//    
//    showToast("请查看控制台");
}

- (void)exampleToNumber {
    {
        NSInteger integerValue = 0;
        NSString *stringValue = nil;
        
        stringValue = @"0";
        integerValue = NSIntegerMake(stringValue, 10, 444);
        NSLog(@"%@ => %ld", stringValue, integerValue);
        
        stringValue = @"123";
        integerValue = NSIntegerMake(stringValue, 10, 444);
        NSLog(@"%@ => %ld", stringValue, integerValue);
        
        stringValue = @"-123";
        integerValue = NSIntegerMake(stringValue, 10, 444);
        NSLog(@"%@ => %ld", stringValue, integerValue);
        
        stringValue = @"0x123";
        integerValue = NSIntegerMake(stringValue, 16, 444);
        NSLog(@"%@ => %ld", stringValue, integerValue);
        
        stringValue = @"0123";
        integerValue = NSIntegerMake(stringValue, 0, 444);
        NSLog(@"%@ => %ld", stringValue, integerValue);
        
        stringValue = @"0x123";
        integerValue = NSIntegerMake(stringValue, 16, 444);
        NSLog(@"%@ => %ld", stringValue, integerValue);
        
        stringValue = @"12.3";
        integerValue = NSIntegerMake(stringValue, 10, 444);
        NSLog(@"%@ => %ld", stringValue, integerValue);
    }
    
}


@end
