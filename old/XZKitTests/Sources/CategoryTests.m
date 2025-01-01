//
//  CategoryTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/2/15.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface CategoryTests : XCTestCase

@end

@implementation CategoryTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testUIColor {
    {
        XZColor value = UIColor.redColor.XZColor;
        XCTAssert(value.red == 255 && value.green == 0 && value.blue == 0 && value.alpha == 255);
        
        value = UIColor.greenColor.XZColor;
        XCTAssert(value.red == 0 && value.green == 255 && value.blue == 0 && value.alpha == 255);
        
        value = UIColor.blueColor.XZColor;
        XCTAssert(value.red == 0 && value.green == 0 && value.blue == 255 && value.alpha == 255);
        
        value = UIColor.clearColor.XZColor;
        XCTAssert(value.red == 0 && value.green == 0 && value.blue == 0 && value.alpha == 0);
    }
    
    { // 测试 rgb 函数
        UIColor *color = rgb(0x112233);
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0xff);
    } {
        UIColor *color = rgb(0x11, 0x22, 0x33);
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0xff);
    } {
        UIColor *color = rgb(0.1, 0.2, 0.3);
        XZColor value = color.XZColor;
        XCTAssert(value.red == round(0.1 * 255) && value.green == round(0.2 * 255) && value.blue == round(0.3 * 255) && value.alpha == 0xff);
    } {
        UIColor *color = rgb(@"0x112233");
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0xff);
    }
    
    { // 测试 rgba 函数
        UIColor *color = rgba(0x11223344);
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0x44);
    } {
        UIColor *color = rgba(0x11, 0x22, 0x33, 0x44);
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0x44);
    } {
        UIColor *color = rgba(0.1, 0.2, 0.3, 0.4);
        XZColor value = color.XZColor;
        XCTAssert(value.red == round(0.1 * 255) && value.green == round(0.2 * 255) && value.blue == round(0.3 * 255) && value.alpha == round(0.4 * 255));
    } {
        UIColor *color = rgba(@"0x11223344");
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x11 && value.green == 0x22 && value.blue == 0x33 && value.alpha == 0x44);
    }
    
    { // 异常 case 测试
        UIColor *color = rgba(@"color: #00FF0033;");
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x00 && value.green == 0xff && value.blue == 0x00 && value.alpha == 0x33);
    } {
        UIColor *color = rgba(@"1234567890");
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x12 && value.green == 0x34 && value.blue == 0x56 && value.alpha == 0x78);
    } {
        UIColor *color = rgba(@"中国12345678人90");
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x12 && value.green == 0x34 && value.blue == 0x56 && value.alpha == 0x78);
    } {
        UIColor *color = rgba(@"好12对34🈚️567890");
        XZColor value = color.XZColor;
        XCTAssert(value.red == 0x56 && value.green == 0x78 && value.blue == 0x90 && value.alpha == 0xff);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
