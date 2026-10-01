//
//  XZEmptyTests.m
//  ExampleTests
//
//  Created by 徐臻 on 2026/10/2.
//

#import <XCTest/XCTest.h>
@import XZKit;

@interface XZEmptyTests : XCTestCase

@end

@implementation XZEmptyTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testXZEmpty {
    {
        NSString *aString = nil;
        XCTAssert(isNonEmpty(aString) == NO);
        
        aString = (id)NSNull.null;
        XCTAssert(isNonEmpty(aString) == NO);
        
        aString = @"";
        XCTAssert(isNonEmpty(aString) == NO);
        
        aString = @"String";
        XCTAssert(isNonEmpty(aString) == YES);
        
        NSLog(@"isNonEmpty(NSString *) => Pass");
    } {
        NSArray *anArray = nil;
        XCTAssert(isNonEmpty(anArray) == NO);
        
        anArray = (id)NSNull.null;
        XCTAssert(isNonEmpty(anArray) == NO);
        
        anArray = @[];
        XCTAssert(isNonEmpty(anArray) == NO);
        
        anArray = @[@"Array"];
        XCTAssert(isNonEmpty(anArray) == YES);
        
        NSLog(@"isNonEmpty(NSArray *) => Pass");
    } {
        NSMutableArray *aMutableArray = nil;
        XCTAssert(isNonEmpty(aMutableArray) == NO);
        
        aMutableArray = (id)NSNull.null;
        XCTAssert(isNonEmpty(aMutableArray) == NO);
        
        aMutableArray = NSMutableArray.array;
        XCTAssert(isNonEmpty(aMutableArray) == NO);
        
        aMutableArray = [NSMutableArray arrayWithObject:@"MutableArray"];
        XCTAssert(isNonEmpty(aMutableArray) == YES);
        
        NSLog(@"isNonEmpty(NSMutableArray *) => Pass");
    } {
        NSSet *aSet = nil;
        XCTAssert(isNonEmpty(aSet) == NO);
        
        aSet = (id)NSNull.null;
        XCTAssert(isNonEmpty(aSet) == NO);
        
        aSet = NSSet.set;
        XCTAssert(isNonEmpty(aSet) == NO);
        
        aSet = [NSSet setWithObject:@"MutableArray"];
        XCTAssert(isNonEmpty(aSet) == YES);
        
        NSLog(@"isNonEmpty(NSSet *) => Pass");
    } {
        NSMutableSet *aMutableSet = nil;
        XCTAssert(isNonEmpty(aMutableSet) == NO);
        
        aMutableSet = (id)NSNull.null;
        XCTAssert(isNonEmpty(aMutableSet) == NO);
        
        aMutableSet = NSMutableSet.set;
        XCTAssert(isNonEmpty(aMutableSet) == NO);
        
        aMutableSet = [NSMutableSet setWithObject:@"MutableArray"];
        XCTAssert(isNonEmpty(aMutableSet) == YES);
        
        NSLog(@"isNonEmpty(NSMutableSet *) => Pass");
    } {
        NSDictionary *aDictionary = nil;
        XCTAssert(isNonEmpty(aDictionary) == NO);
        
        aDictionary = (id)NSNull.null;
        XCTAssert(isNonEmpty(aDictionary) == NO);
        
        aDictionary = @{ };
        XCTAssert(isNonEmpty(aDictionary) == NO);
        
        aDictionary = @{ @"Key": @"Value" };
        XCTAssert(isNonEmpty(aDictionary) == YES);
        
        NSLog(@"isNonEmpty(NSDictionary *) => Pass");
    } {
        NSMutableDictionary *aMutableDictionary = nil;
        XCTAssert(isNonEmpty(aMutableDictionary) == NO);
        
        aMutableDictionary = (id)NSNull.null;
        XCTAssert(isNonEmpty(aMutableDictionary) == NO);
        
        aMutableDictionary = NSMutableDictionary.dictionary;
        XCTAssert(isNonEmpty(aMutableDictionary) == NO);
        
        aMutableDictionary = [NSMutableDictionary dictionaryWithObject:@"Value" forKey:@"Key"];
        XCTAssert(isNonEmpty(aMutableDictionary) == YES);
        
        NSLog(@"isNonEmpty(NSMutableDictionary *) => Pass");
    } {
        NSNumber *aNumber = nil;
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = (id)NSNull.null;
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = [NSNumber numberWithBool:false];
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = [NSNumber numberWithInt:0];
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = [NSNumber numberWithDouble:0];
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = [NSNumber numberWithInt:10];
        XCTAssert(isNonEmpty(aNumber) == YES);
        
        NSLog(@"isNonEmpty(NSNumber *) => Pass");
    } {
        UIView *anObject = nil;
        XCTAssert(isNonEmpty(anObject) == NO);
        
        anObject = (id)NSNull.null;
        XCTAssert(isNonEmpty(anObject) == NO);
        
        anObject = [[UIView alloc] init];
        XCTAssert(isNonEmpty(anObject) == YES);
        
        anObject = (id)NSUUID.UUID;
        XCTAssert(isNonEmpty(anObject) == YES);
        
        NSLog(@"isNonEmpty(UIView *) => Pass");
    }
    
    {
        id value = nil;
        XCTAssert([asNonEmpty(value, @"123") isEqualToString:@"123"]);
        XCTAssert(asNonEmpty(value, (NSString *)nil) == nil);
        
        value = @"";
        XCTAssert([asNonEmpty(value, @"123") isEqualToString:@"123"]);
        XCTAssert(asNonEmpty(value, (NSString *)nil) == nil);
        
        value = @"456";
        XCTAssert([asNonEmpty(value, @"123") isEqualToString:@"456"]);
        XCTAssert([asNonEmpty(value, (NSString *)nil) isEqualToString:@"456"]);
    } {
        id value = nil;
        XCTAssert([asNonEmpty(value, @[@"123"]) isEqualToArray:@[@"123"]]);
        XCTAssert(asNonEmpty(value, (NSArray *)nil) == nil);
        
        value = @[];
        XCTAssert([asNonEmpty(value, @[@"123"]) isEqualToArray:@[@"123"]]);
        XCTAssert(asNonEmpty(value, (NSArray *)nil) == nil);
        
        value = @[@"456"];
        XCTAssert([asNonEmpty(value, @[@"123"]) isEqualToArray:@[@"456"]]);
        XCTAssert([asNonEmpty(value, (NSArray *)nil) isEqualToArray:@[@"456"]]);
    } {
        id value = nil;
        XCTAssert([asNonEmpty(value, [NSSet setWithObject:@"123"]) isEqualToSet:[NSSet setWithObject:@"123"]]);
        XCTAssert(asNonEmpty(value, (NSSet *)nil) == nil);
        
        value = [NSSet set];
        XCTAssert([asNonEmpty(value, [NSSet setWithObject:@"123"]) isEqualToSet:[NSSet setWithObject:@"123"]]);
        XCTAssert(asNonEmpty(value, (NSSet *)nil) == nil);
        
        value = [NSSet setWithObject:@"456"];
        XCTAssert([asNonEmpty(value, [NSSet setWithObject:@"123"]) isEqualToSet:[NSSet setWithObject:@"456"]]);
        XCTAssert([asNonEmpty(value, (NSSet *)nil) isEqualToSet:[NSSet setWithObject:@"456"]]);
    } {
        id value = nil;
        XCTAssert([asNonEmpty(value, @{@"Key": @"Value"}) isEqualToDictionary:@{@"Key": @"Value"}]);
        XCTAssert(asNonEmpty(value, (NSDictionary *)nil) == nil);
        
        value = @{};
        XCTAssert([asNonEmpty(value, @{@"Key": @"Value"}) isEqualToDictionary:@{@"Key": @"Value"}]);
        XCTAssert(asNonEmpty(value, (NSDictionary *)nil) == nil);
        
        value = @{@"Key1": @"Value1"};
        XCTAssert([asNonEmpty(value, @{@"Key": @"Value"}) isEqualToDictionary:@{@"Key1": @"Value1"}]);
        XCTAssert([asNonEmpty(value, (NSDictionary *)nil) isEqualToDictionary:@{@"Key1": @"Value1"}]);
    } {
        id value = nil;
        XCTAssert([asNonEmpty(value, @(10)) isEqualToNumber:@(10)]);
        XCTAssert(asNonEmpty(value, (NSNumber *)nil) == nil);
        
        value = [NSNumber numberWithInt:0];
        XCTAssert([asNonEmpty(value, @(10)) isEqualToNumber:@(10)]);
        XCTAssert(asNonEmpty(value, (NSNumber *)nil) == nil);
        
        value = [NSNumber numberWithInt:20];
        XCTAssert([asNonEmpty(value, @(10)) isEqualToNumber:@(20)]);
        XCTAssert([asNonEmpty(value, (NSNumber *)nil) isEqualToNumber:@(20)]);
    } {
        id value = nil;
        
        NSURL * const defaultValue = [NSURL URLWithString:@"https://www.xezun.com/"];
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:defaultValue]);
        XCTAssert(asNonEmpty(value, (NSURL *)nil) == nil);
        
        value = [NSURL URLWithString:@""];
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:defaultValue]);
        XCTAssert(asNonEmpty(value, (NSURL *)nil) == nil);
        
        value = [NSURL URLWithString:@"http://xzkit.xezun.com/"];
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:[NSURL URLWithString:@"http://xzkit.xezun.com/"]]);
        XCTAssert([asNonEmpty(value, (NSURL *)nil) isEqual:[NSURL URLWithString:@"http://xzkit.xezun.com/"]]);
    }{
        id value = nil;
        UIView * const defaultValue = [[UIView alloc] init];
        
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:defaultValue]);
        XCTAssert(asNonEmpty(value, (UIView *)nil) == nil);
        
        value = NSNull.null;
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:defaultValue]);
        XCTAssert(asNonEmpty(value, (UIView *)nil) == nil);
        
        value = [NSUUID UUID];
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:value]);
        XCTAssert([asNonEmpty(value, (UIView *)nil) isEqual:value]);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
