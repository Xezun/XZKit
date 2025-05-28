//
//  XZMocoaTests.m
//  ExampleTests
//
//  Created by 徐臻 on 2025/5/29.
//

#import <XCTest/XCTest.h>
@import XZMocoa;
@import XZDefines;

@interface XZMocoaTests : XCTestCase

@end

@implementation XZMocoaTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    XZMocoaViewModel *viewModel = [[XZMocoaViewModel alloc] initWithModel:nil];
    
    [viewModel addTarget:self action:@selector(boolValueChanged:) forKey:@"boolValue"];
    [viewModel sendActionsForKey:@"boolValue" value:@(YES)];
    [viewModel sendActionsForKey:@"boolValue" value:@(NO)];
    
    [viewModel addTarget:self action:@selector(int8ValueChanged:) forKey:@"int8Value"];
    [viewModel sendActionsForKey:@"int8Value" value:@(123)];
    [viewModel sendActionsForKey:@"int8Value" value:@(-123)];
    
    [viewModel addTarget:self action:@selector(int16ValueChanged:) forKey:@"int16Value"];
    [viewModel sendActionsForKey:@"int16Value" value:@((int16_t)123)];
    [viewModel sendActionsForKey:@"int16Value" value:@((int16_t)-123)];
    
    [viewModel addTarget:self action:@selector(int32ValueChanged:) forKey:@"int32Value"];
    [viewModel sendActionsForKey:@"int32Value" value:@((int32_t)123)];
    [viewModel sendActionsForKey:@"int32Value" value:@((int32_t)-123)];
    
    [viewModel addTarget:self action:@selector(int64ValueChanged:) forKey:@"int64Value"];
    [viewModel sendActionsForKey:@"int64Value" value:@(123)];
    [viewModel sendActionsForKey:@"int64Value" value:@(-123)];
    
    [viewModel addTarget:self action:@selector(integerValueChanged:) forKey:@"integerValue"];
    [viewModel sendActionsForKey:@"integerValue" value:@((NSInteger)123)];
    [viewModel sendActionsForKey:@"integerValue" value:@((NSInteger)-123)];
    
    [viewModel addTarget:self action:@selector(floatValueChanged:) forKey:@"floatValue"];
    [viewModel sendActionsForKey:@"floatValue" value:@(12.35)];
    [viewModel sendActionsForKey:@"floatValue" value:@(-1.23)];

    [viewModel addTarget:self action:@selector(doubleValueChanged:) forKey:@"doubleValue"];
    [viewModel sendActionsForKey:@"doubleValue" value:@(12.35)];
    [viewModel sendActionsForKey:@"doubleValue" value:@(-1.23)];

    [viewModel addTarget:self action:@selector(rectValueChanged:) forKey:@"rectValue"];
    [viewModel sendActionsForKey:@"rectValue" value:@(CGRectMake(10, 20, 30, 40))];
    [viewModel sendActionsForKey:@"rectValue" value:@(CGRectMake(30, 20, 10, 50))];
    
    [viewModel addTarget:self action:@selector(pointerValueChanged:) forKey:@"pointerValue"];
    [viewModel sendActionsForKey:@"pointerValue" value:[NSValue valueWithPointer:(__bridge const void * _Nullable)(self)]];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)boolValueChanged:(BOOL)value {
    XZLog(@"%d", value);
}

- (void)int8ValueChanged:(int8_t)value {
    XZLog(@"%d", value);
}

- (void)int16ValueChanged:(int16_t)value {
    XZLog(@"%d", value);
}

- (void)int32ValueChanged:(int32_t)value {
    XZLog(@"%d", value);
}

- (void)int64ValueChanged:(int64_t)value {
    XZLog(@"%lld", value);
}

- (void)integerValueChanged:(NSInteger)value {
    XZLog(@"%ld", value);
}

- (void)floatValueChanged:(float)value {
    XZLog(@"%f", value);
}

- (void)doubleValueChanged:(double)value {
    XZLog(@"%f", value);
}

- (void)rectValueChanged:(CGRect)value {
    XZLog(@"%@", NSStringFromCGRect(value));
}

- (void)pointerValueChanged:(void *)value {
    XZLog(@"%p - %p", self, value);
}

@end
