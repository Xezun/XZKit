//
//  XZFoundationURLTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/8/15.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface XZFoundationURLTests : XCTestCase

@end

@implementation XZFoundationURLTests

- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testExample {
    XZURLQuery *query = [XZURLQuery URLQueryWithString:@"https://www.xezun.com/?key1=value1&key2=&key3"];;
    NSLog(@"原始：%@", query.url);
    
    XCTAssert([[query valueForField:@"key1"] isEqual:@"value1"]);
    XCTAssert([[query valueForField:@"key2"] isEqual:@""]);
    XCTAssert([query valueForField:@"key3"] == nil);
    XCTAssert([query valueForField:@"key4"] == nil);
    
    [query setValue:@"123" forField:@"key4"];
    XCTAssert([[query valueForField:@"key4"] isEqual:@"123"]);
    XZPrint(@"设置 key4 = 123：%@", query.url);
    
    [query addValue:@"1" forField:@"key4"];
    XZPrint(@"添加 key4 = 1  ：%@", query.url);
    
    [query addValue:nil forField:@"key4"];
    XZPrint(@"添加 key4 = nil：%@", query.url);
    
    [query removeValue:nil forField:@"key4"];
    XZPrint(@"移除 key4 = nil：%@", query.url);
    
    [query removeField:@"key1"];
    XZPrint(@"移除 key1      ：%@", query.url);
    
    XCTAssert(![query containsField:@"key1"]);
    XCTAssert([query containsField:@"key2"]);
    XCTAssert([query containsField:@"key3"]);
    XCTAssert([query containsField:@"key4"]);
    XCTAssert(![query containsField:@"key5"]);
    
    [query addValuesForFieldsFromObject:@{
        @"A": @"1",
        @"B": @"2",
        @"C": @"3",
        @"D": @"4"
    }];
    XZPrint(@"添加字典字段     ：%@", query.url);
    
    [query addValuesForFieldsFromObject:@[@"A", @"B", @"C"]];
    XZPrint(@"添加数组字段     ：%@", query.url);
    
    [query setValuesForFieldsWithObject:@{
        @"A": @"1",
        @"B": @"2",
        @"C": @"3",
        @"D": @"4"
    }];
    XZPrint(@"设置字典字段     ：%@", query.url);
    
    [query setValuesForFieldsWithObject:@[@"A", @"B", @"C"]];
    XZPrint(@"设置数组字段     ：%@", query.url);
    
    [query removeAllFields];
    XZPrint(@"移除所有字段     ：%@", query.url);
    
    [query setValue:@[] forField:@"name"];
    XZPrint(@"%@", query.url);
    
    [query setValue:@[@"1", @"2", @"3"] forField:@"name"];
    XZPrint(@"%@", query.url);
    
    [query addValue:@[@"5", @"6", @"7"] forField:@"name"];
    XZPrint(@"%@", query.url);
    
//    [query removeAllNamesAndValues];
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
