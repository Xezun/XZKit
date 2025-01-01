//
//  DataDigesterTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/2/10.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface DataDigesterTests : XCTestCase

@end

@implementation DataDigesterTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMD5 {
    NSString *strRaw = @"XZKit 教程";
    NSString *strMD5 = @"07538864E2A7306CB560AAB785E4E265";
    NSString *strSHA1 = @"C152ADAE72EDECD473D232B0D7AA4D6D1585F2A9";
    
    NSString *MD5 = strRaw.xz_MD5;
    XCTAssert([MD5 isEqual:strMD5]);
    
    NSString *SHA1 = strRaw.xz_SHA1;
    XCTAssert([SHA1 isEqual:strSHA1]);
    
    
}

- (void)testAES {
    NSString *str = @"123";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *key = @"123";
    NSString *vector = @"1234567890123456";
    
    {
        NSError *error = nil;
        NSData *ento = [XZDataCryptor AESEncrypt:data key:key vector:vector error:&error];
        
        if (error.code == noErr) {
            XZLog(@"%@", [ento xz_hexEncodedString]);
        }
        
        NSData *deto = [XZDataCryptor AESDecrypt:ento key:key vector:vector error:nil];
        XZLog(@"%@", [[NSString alloc] initWithData:deto encoding:NSUTF8StringEncoding]);
    }
    
    {
        XZDataCryptor *encryptor = [XZDataCryptor AESEncryptor:key vector:vector];
        
        NSMutableData *dataM = [NSMutableData data];
        NSData *tmp = [encryptor crypto:data error:nil];
        [dataM appendData:tmp];
        [dataM appendData:[encryptor finish:nil]];
        
        XZLog(@"%@", [dataM xz_hexEncodedString]);
        
        XZDataCryptor *decryptor = [XZDataCryptor AESDecryptor:key vector:vector];

        NSMutableData *dataM2 = [NSMutableData data];
        [dataM2 appendData:[decryptor crypto:dataM error:nil]];
        [dataM2 appendData:[decryptor finish:nil]];
        XZLog(@"%@", [[NSString alloc] initWithData:dataM2 encoding:NSUTF8StringEncoding]);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
