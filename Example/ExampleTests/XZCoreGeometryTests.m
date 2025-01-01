//
//  XZGeometryTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/7/25.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface XZGeometryTests : XCTestCase

@end

@implementation XZGeometryTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    XCTAssert(XZEdgeInsetsZero.top == 0);
    XCTAssert(XZEdgeInsetsZero.leading == 0);
    XCTAssert(XZEdgeInsetsZero.bottom == 0);
    XCTAssert(XZEdgeInsetsZero.trailing == 0);
    
    XZEdgeInsets edge1 = XZEdgeInsetsMake(10, 20, 30, 40);
    XCTAssert(edge1.top == 10 && edge1.leading == 20 && edge1.bottom == 30 && edge1.trailing == 40);
    
    XZEdgeInsets edge2 = XZEdgeInsetsMake(11, 22, 33, 44);
    XCTAssert(edge2.top == 11 && edge2.leading == 22 && edge2.bottom == 33 && edge2.trailing == 44);
    
    XCTAssert(XZEdgeInsetsEqualToEdgeInsets(edge1, edge1));
    XCTAssert(XZEdgeInsetsEqualToEdgeInsets(edge2, edge2));
    XCTAssert(!XZEdgeInsetsEqualToEdgeInsets(edge1, edge2));
    
    UIEdgeInsets edge3 = UIEdgeInsetsMake(10, 20, 30, 40);
    XZEdgeInsets edge4 = XZEdgeInsetsFromUIEdgeInsets(edge3, UIUserInterfaceLayoutDirectionLeftToRight);
    XCTAssert(edge4.top == 10 && edge4.leading == 20 && edge4.bottom == 30 && edge4.trailing == 40);
    XZEdgeInsets edge5 = XZEdgeInsetsFromUIEdgeInsets(edge3, UIUserInterfaceLayoutDirectionRightToLeft);
    XCTAssert(edge5.top == 10 && edge5.leading == 40 && edge5.bottom == 30 && edge5.trailing == 20);
}

- (void)testCGRectAdjustSize {
    CGRect const bounds = CGRectMake(0, 0, 100, 200);
    
    CGRect frame = CGRectAdjustSize(bounds, CGSizeMake(300, 300), XZAdjustModeScaleToFill);
    XCTAssert(CGRectEqualToRect(bounds, frame));
    
    frame = CGRectAdjustSize(bounds, CGSizeMake(10, 10), XZAdjustModeScaleToFill);
    XCTAssert(CGRectEqualToRect(bounds, frame));
    
    frame = CGRectAdjustSize(bounds, CGSizeMake(300, 300), XZAdjustModeScaleAspectFit);
    XCTAssert(CGRectEqualToRect(frame, CGRectMake(0, 50, 100, 100)));
    
    frame = CGRectAdjustSize(bounds, CGSizeMake(300, 300), XZAdjustModeScaleAspectFit | XZAdjustModeTop);
    XCTAssert(CGRectEqualToRect(frame, CGRectMake(0, 0, 100, 100)));
    
    frame = CGRectAdjustSize(bounds, CGSizeMake(300, 300), XZAdjustModeScaleAspectFill);
    XCTAssert(CGRectEqualToRect(frame, CGRectMake(-50, 0, 200, 200)));
    
    frame = CGRectAdjustSize(bounds, CGSizeMake(300, 300), XZAdjustModeCenter);
    XCTAssert(CGRectEqualToRect(frame, CGRectMake(-100, -50, 300, 300)));
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
