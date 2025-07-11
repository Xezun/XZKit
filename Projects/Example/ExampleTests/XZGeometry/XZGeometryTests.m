//
//  XZGeometryTests.m
//  ExampleTests
//
//  Created by 徐臻 on 2025/5/13.
//

#import <XCTest/XCTest.h>
@import XZKit;

@interface XZGeometryTests : XCTestCase

@end

@implementation XZGeometryTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEdgeInsets {
    {
        NSDirectionalEdgeInsets edgeInsets = NSDirectionalEdgeInsetsFromUIEdgeInsets(UIEdgeInsetsMake(1, 2, 3, 4), UIUserInterfaceLayoutDirectionLeftToRight);
        XCTAssert(edgeInsets.top == 1 && edgeInsets.leading == 2 && edgeInsets.bottom == 3 && edgeInsets.trailing == 4);
    }
    
    {
        NSDirectionalEdgeInsets edgeInsets = NSDirectionalEdgeInsetsFromUIEdgeInsets(UIEdgeInsetsMake(1, 2, 3, 4), UIUserInterfaceLayoutDirectionRightToLeft);
        XCTAssert(edgeInsets.top == 1 && edgeInsets.leading == 4 && edgeInsets.bottom == 3 && edgeInsets.trailing == 2);
    }
    
    {
        UIEdgeInsets edgeInsets = UIEdgeInsetsFromNSDirectionalEdgeInsets(NSDirectionalEdgeInsetsMake(1, 2, 3, 4), UIUserInterfaceLayoutDirectionLeftToRight);
        XCTAssert(edgeInsets.top == 1 && edgeInsets.left == 2 && edgeInsets.bottom == 3 && edgeInsets.right == 4);
    }
    
    {
        UIEdgeInsets edgeInsets = UIEdgeInsetsFromNSDirectionalEdgeInsets(NSDirectionalEdgeInsetsMake(1, 2, 3, 4), UIUserInterfaceLayoutDirectionRightToLeft);
        XCTAssert(edgeInsets.top == 1 && edgeInsets.left == 4 && edgeInsets.bottom == 3 && edgeInsets.right == 2);
    }
    
}

- (void)testCGRectContainsPointInEdgeInsets {
    XCTAssert(CGRectContainsPointInEdgeInsets(CGRectMake(0, 0, 100, 100), UIEdgeInsetsMake(10, 10, 10, 10), CGPointMake(50.0, 5.0)));
    XCTAssert(CGRectContainsPointInEdgeInsets(CGRectMake(0, 0, 100, 100), UIEdgeInsetsMake(10, 10, 10, 10), CGPointMake(55.0, 95.0)));
    XCTAssert(CGRectContainsPointInEdgeInsets(CGRectMake(0, 0, 100, 100), UIEdgeInsetsMake(10, 10, 10, 10), CGPointMake(5.0, 50.0)));
    XCTAssert(CGRectContainsPointInEdgeInsets(CGRectMake(0, 0, 100, 100), UIEdgeInsetsMake(10, 10, 10, 10), CGPointMake(95.0, 50.0)));
    XCTAssert(!CGRectContainsPointInEdgeInsets(CGRectMake(0, 0, 100, 100), UIEdgeInsetsMake(10, 10, 10, 10), CGPointMake(50.0, 50.0)));
}

- (void)testCGSizeMakeAspectRatioInside {
    CGSize const size = CGSizeMake(100, 100);
    XCTAssert(CGSizeEqualToSize(CGSizeMakeAspectRatioInside(size, CGSizeMake(2.0, 1.0)), CGSizeMake(100, 50)));
    XCTAssert(CGSizeEqualToSize(CGSizeMakeAspectRatioInside(size, CGSizeMake(1.0, 2.0)), CGSizeMake(50, 100)));
    XCTAssert(CGSizeEqualToSize(CGSizeMakeAspectRatioInside(size, CGSizeMake(1.0, 1.0)), CGSizeMake(100, 100)));
}

- (void)testCGSizeScaleAspectRatioInside {
    CGSize const size = CGSizeMake(100, 100);
    XCTAssert(CGSizeEqualToSize(CGSizeScaleAspectRatioInside(size, CGSizeMake(200, 100)), CGSizeMake(100, 50)));
    XCTAssert(CGSizeEqualToSize(CGSizeScaleAspectRatioInside(size, CGSizeMake(100, 200)), CGSizeMake(50, 100)));
    XCTAssert(CGSizeEqualToSize(CGSizeScaleAspectRatioInside(size, CGSizeMake(10, 200)), CGSizeMake(5, 100)));
    XCTAssert(CGSizeEqualToSize(CGSizeScaleAspectRatioInside(size, CGSizeMake(200, 10)), CGSizeMake(100, 5)));
    XCTAssert(CGSizeEqualToSize(CGSizeScaleAspectRatioInside(size, CGSizeMake(25, 75)), CGSizeMake(25, 75)));
}

- (void)testCGRectMakeAspectRatioWithMode {
    {
        CGRect const rect = CGRectMake(100, 100, 300, 100);
        CGRect const newRect = CGRectMakeAspectRatioWithMode(rect, CGSizeMake(500, 500), UIViewContentModeScaleToFill);
        XCTAssert(CGRectEqualToRect(newRect, CGRectMake(100, 100, 300, 100)));
    }
    
    {
        CGRect const rect = CGRectMake(100, 100, 0, 100);
        CGRect const newRect = CGRectMakeAspectRatioWithMode(rect, CGSizeMake(500, 500), UIViewContentModeScaleAspectFit);
        XCTAssert(CGRectEqualToRect(newRect, CGRectMake(100, 150, 0, 0)));
    }
    
    {
        CGRect const rect = CGRectMake(100, 100, 300, 0);
        CGRect const newRect = CGRectMakeAspectRatioWithMode(rect, CGSizeMake(500, 500), UIViewContentModeScaleAspectFit);
        XCTAssert(CGRectEqualToRect(newRect, CGRectMake(250, 100, 0, 0)));
    }
    
    {
        CGRect const rect = CGRectMake(100, 100, 300, 100);
        CGRect const newRect = CGRectMakeAspectRatioWithMode(rect, CGSizeMake(500, 500), UIViewContentModeScaleAspectFit);
        XCTAssert(CGRectEqualToRect(newRect, CGRectMake(200, 100, 100, 100)));
    }
    
    {
        CGRect const rect = CGRectMake(100, 100, 300, 100);
        CGRect const newRect = CGRectMakeAspectRatioWithMode(rect, CGSizeMake(500, 500), UIViewContentModeScaleAspectFill);
        XCTAssert(CGRectEqualToRect(newRect, CGRectMake(100, 0, 300, 300)));
    }
}

- (void)testCGRectMakeAspectRatioInsideWithMode {
    
}

- (void)testCGRectScaleAspectRatioInsideWithMode {
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
