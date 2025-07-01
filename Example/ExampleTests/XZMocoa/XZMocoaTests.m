//
//  XZMocoaTests.m
//  ExampleTests
//
//  Created by 徐臻 on 2025/5/29.
//

#import <XCTest/XCTest.h>
@import XZMocoaObjC;
@import XZDefines;
@import XZExtensions;

typedef void (*FoobarFunction) (void);
union FoobarUnion { double b; int a; };

static void fooFunction(void) { }
static void barFunction(void) { }

@interface XZMocoaTestsViewModel : XZMocoaViewModel
@end

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
    
    [viewModel addTarget:self action:@selector(functionPointerValueChanged:) forKey:@"functionPointer"];
    [viewModel sendActionsForKey:@"functionPointer" value:[NSValue valueWithPointer:fooFunction]];
    [viewModel sendActionsForKey:@"functionPointer" value:[NSValue valueWithPointer:barFunction]];
    
    [viewModel addTarget:self action:@selector(charValueChanged:) forKey:@"char"];
    [viewModel sendActionsForKey:@"char" value:@((char)'a')];
    [viewModel sendActionsForKey:@"char" value:@((char)'z')];
    
    [viewModel addTarget:self action:@selector(unsignedCharValueChanged:) forKey:@"unsignedChar"];
    [viewModel sendActionsForKey:@"unsignedChar" value:@((unsigned char)100)];
    [viewModel sendActionsForKey:@"unsignedChar" value:@((unsigned char)240)];
    
    [viewModel addTarget:self action:@selector(intValueChanged:) forKey:@"int"];
    [viewModel sendActionsForKey:@"int" value:@((int)+123)];
    [viewModel sendActionsForKey:@"int" value:@((int)-123)];
    
    [viewModel addTarget:self action:@selector(unsignedIntValueChanged:) forKey:@"unsignedInt"];
    [viewModel sendActionsForKey:@"unsignedInt" value:@((unsigned int)+123)];
    [viewModel sendActionsForKey:@"unsignedInt" value:@((unsigned int)-123)];
    
    [viewModel addTarget:self action:@selector(shortValueChanged:) forKey:@"short"];
    [viewModel sendActionsForKey:@"short" value:@((short)+100)];
    [viewModel sendActionsForKey:@"short" value:@((short)+240)];
    
    [viewModel addTarget:self action:@selector(unsignedShortValueChanged:) forKey:@"unsignedShort"];
    [viewModel sendActionsForKey:@"unsignedShort" value:@((unsigned short)+100)];
    [viewModel sendActionsForKey:@"unsignedShort" value:@((unsigned short)+240)];
    
    [viewModel addTarget:self action:@selector(longKey:didChangeValue:) forKey:@"long"];
    [viewModel sendActionsForKey:@"long" value:@((long)+100)];
    [viewModel sendActionsForKey:@"long" value:@((long)+240)];
    
    [viewModel addTarget:self action:@selector(unsignedLongValueChanged:) forKey:@"unsignedLong"];
    [viewModel sendActionsForKey:@"unsignedLong" value:@((unsigned long)+100)];
    [viewModel sendActionsForKey:@"unsignedLong" value:@((unsigned long)+240)];
    
    [viewModel addTarget:self action:@selector(longLongValueChanged:) forKey:@"longLong"];
    [viewModel sendActionsForKey:@"longLong" value:@((long long)+100)];
    [viewModel sendActionsForKey:@"longLong" value:@((long long)+240)];
    
    [viewModel addTarget:self action:@selector(unsignedLongValueChanged:) forKey:@"unsignedLongLong"];
    [viewModel sendActionsForKey:@"unsignedLongLong" value:@((unsigned long long)+100)];
    [viewModel sendActionsForKey:@"unsignedLongLong" value:@((unsigned long long)+240)];
    
    [viewModel addTarget:self action:@selector(floatValueChanged:) forKey:@"float"];
    [viewModel sendActionsForKey:@"float" value:@((float)100)];
    [viewModel sendActionsForKey:@"float" value:@((float)240)];
    
    [viewModel addTarget:self action:@selector(doubleValueChanged:) forKey:@"double"];
    [viewModel sendActionsForKey:@"double" value:@((double)100)];
    [viewModel sendActionsForKey:@"double" value:@((double)240)];
    
    [viewModel addTarget:self action:@selector(boolValueChanged:) forKey:@"bool"];
    [viewModel sendActionsForKey:@"bool" value:@(YES)];
    
    [viewModel addTarget:self action:@selector(stringValueChanged:) forKey:@"string"];
    {
        char *foo = "foo"; char *bar = "bar";
        [viewModel sendActionsForKey:@"string" value:[NSValue valueWithPointer:foo]];
        [viewModel sendActionsForKey:@"string" value:[NSValue valueWithPointer:bar]];
    }
    
    [viewModel addTarget:self action:@selector(selectorValueChanged:) forKey:@"selector"];
    [viewModel sendActionsForKey:@"selector" value:[NSValue valueWithPointer:(void *)(@selector(selectorValueChanged:))]];
    [viewModel sendActionsForKey:@"selector" value:[NSValue valueWithPointer:(void *)(@selector(pointerValueChanged:))]];
    
    [viewModel addTarget:self action:@selector(pointerValueChanged:) forKey:@"pointer"];
    {
        int foo = 100; float bar = 200;
        [viewModel sendActionsForKey:@"pointer" value:[NSValue valueWithPointer:&foo]];
        [viewModel sendActionsForKey:@"pointer" value:[NSValue valueWithPointer:&bar]];
    }
    
    [viewModel addTarget:self action:@selector(arrayValueChanged:) forKey:@"array"];
    {
        int foo[3] = { 1, 2, 3 };
        [viewModel sendActionsForKey:@"array" value:[NSValue valueWithPointer:foo]];
    }
    
    [viewModel addTarget:self action:@selector(unionValueChanged:) forKey:@"union"];
    {
        union FoobarUnion foo;
        foo.a = 100;
        [viewModel sendActionsForKey:@"union" value:[NSValue valueWithBytes:&foo objCType:@encode(union FoobarUnion)]];
        foo.b = 200;
        [viewModel sendActionsForKey:@"union" value:[NSValue valueWithBytes:&foo objCType:@encode(union FoobarUnion)]];
    }
    
    [viewModel addTarget:self action:@selector(rectValueChanged:) forKey:@"rect"];
    [viewModel sendActionsForKey:@"rect" value:@(CGRectMake(10, 20, 30, 40))];
    [viewModel sendActionsForKey:@"rect" value:@(CGRectMake(40, 30, 20, 10))];
    
    [viewModel addTarget:self action:@selector(edgeInsetsValueChanged:) forKey:@"edgeInsets"];
    [viewModel sendActionsForKey:@"edgeInsets" value:@(UIEdgeInsetsMake(10, 20, 30, 40))];
    [viewModel sendActionsForKey:@"edgeInsets" value:@(UIEdgeInsetsMake(40, 30, 20, 10))];
    
    [viewModel addTarget:self action:@selector(classValueChanged:) forKey:@"class"];
    [viewModel sendActionsForKey:@"class" value:NSObject.class];
    [viewModel sendActionsForKey:@"class" value:NSProxy.class];

    [viewModel addTarget:self action:@selector(viewModel:key:didChangeObjectValue:) forKey:@"object"];
    [viewModel sendActionsForKey:@"object" value:self];
    [viewModel sendActionsForKey:@"object" value:viewModel];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)functionPointerValueChanged:(FoobarFunction)value {
    XCTAssert(value == fooFunction || value == barFunction);
}

- (void)charValueChanged:(char)value {
    XCTAssert(value == 'a' || value == 'z');
}

- (void)unsignedCharValueChanged:(unsigned char)value {
    XCTAssert(value == 100 || value == 240);
}

- (void)intValueChanged:(int)value {
    XCTAssert(value == 123 || value == -123);
}

- (void)unsignedIntValueChanged:(unsigned int)value {
    XCTAssert(value == 123 || value == -123);
}

- (void)shortValueChanged:(short)value {
    XCTAssert(value == 100 || value == 240);
}

- (void)unsignedShortValueChanged:(unsigned short)value {
    XCTAssert(value == 100 || value == 240);
}

- (void)longKey:(XZMocoaKey)key didChangeValue:(long)value {
    XCTAssert([key isEqualToString:@"long"]);
    XCTAssert(value == 100 || value == 240);
}

- (void)unsignedLongValueChanged:(unsigned long)value {
    XCTAssert(value == 100 || value == 240);
}

- (void)longLongValueChanged:(long long)value {
    XCTAssert(value == 100 || value == 240);
}

- (void)unsignedLongLongValueChanged:(unsigned long long)value {
    XCTAssert(value == 100 || value == 240);
}

- (void)floatValueChanged:(float)value {
    XCTAssert(value == 100 || value == 240);
}

- (void)doubleValueChanged:(double)value {
    XCTAssert(value == 100 || value == 240);
}

- (void)boolValueChanged:(BOOL)value {
    XCTAssert(value == YES);
}

// void

- (void)stringValueChanged:(char *)value {
    XCTAssert(strcmp(value, "foo") == 0 || strcmp(value, "bar") == 0);
}

- (void)selectorValueChanged:(SEL)value {
    XCTAssert(value == @selector(selectorValueChanged:) || value == @selector(pointerValueChanged:));
}

- (void)pointerValueChanged:(void *)value {
    XCTAssert(*((int *)value) == 100 || *((float *)value) == 200);
}

- (void)arrayValueChanged:(int[3])value {
    XCTAssert(value[0] == 1 || value[1] == 2 || value[2] == 3);
}

// bitfield

- (void)unionValueChanged:(union FoobarUnion)value {
    XCTAssert(value.a == 100 || value.b == 200);
}

- (void)rectValueChanged:(CGRect)value {
    XCTAssert(CGRectEqualToRect(value, CGRectMake(10, 20, 30, 40)) || CGRectEqualToRect(value, CGRectMake(40, 30, 20, 10)));
}

- (void)edgeInsetsValueChanged:(UIEdgeInsets)value {
    XCTAssert(UIEdgeInsetsEqualToEdgeInsets(value, UIEdgeInsetsMake(10, 20, 30, 40)) || UIEdgeInsetsEqualToEdgeInsets(value, UIEdgeInsetsMake(40, 30, 20, 10)));
}

- (void)classValueChanged:(Class)value {
    XCTAssert(value == NSObject.class || value == NSProxy.class);
}

- (void)viewModel:(XZMocoaViewModel *)viewModel key:(XZMocoaKey)key didChangeObjectValue:(id)value {
    XCTAssert([key isEqualToString:@"object"]);
    XCTAssert([viewModel isKindOfClass:[XZMocoaViewModel class]]);
    XCTAssert(value == self || value == viewModel);
}

- (void)testUnionConvertion {
    NSLog(@"%lu == %lu", sizeof(double), sizeof(union FoobarUnion));
    {
        union FoobarUnion u;
        
        {
            u.b = 0x123456;
            double b = 0x123456;
            UInt8 *byteU = (UInt8 *)&u;
            NSLog(@"%02X%02X%02X%02X%02X%02X%02X%02X", byteU[0],byteU[1],byteU[2],byteU[3],byteU[4],byteU[5],byteU[6],byteU[7]);
            
            UInt8 *byteB = (UInt8 *)&b;
            NSLog(@"%02X%02X%02X%02X%02X%02X%02X%02X", byteB[0],byteB[1],byteB[2],byteB[3],byteB[4],byteB[5],byteB[6],byteB[7]); // 0000000056343241
        }
        
        {
            u.a = 0x123456;
            NSInteger a = 0x123456;
            UInt8 *byteU = (UInt8 *)&u;
            NSLog(@"%02X%02X%02X%02X%02X%02X%02X%02X", byteU[0],byteU[1],byteU[2],byteU[3],byteU[4],byteU[5],byteU[6],byteU[7]);
            
            UInt8 *byteB = (UInt8 *)&a;
            NSLog(@"%02X%02X%02X%02X%02X%02X%02X%02X", byteB[0],byteB[1],byteB[2],byteB[3],byteB[4],byteB[5],byteB[6],byteB[7]); // 5634120000000000
        }
        
        // double 类型：1 符号位，11 指数位，52 小数位
    }
    
    {
        union FoobarUnion u;
        u.a = 100;
        
        ((void (*)(id,SEL,int))(objc_msgSend))(self, @selector(printIntValue:), *(int *)&u);
        
        u.b = 200;
        ((void (*)(id,SEL,double))(objc_msgSend))(self, @selector(printDoubleValue:), *(double *)&u);
    }
    
    {
        union FoobarUnion u;
        u.a = 100;
        NSValue *value = [NSValue valueWithBytes:&u objCType:@encode(union FoobarUnion)];
        
        union FoobarUnion n;
        [value getValue:&n size:sizeof(union FoobarUnion)];
        [self printUnionValueA:n];
        
        double d = 0;
        [value getValue:&d size:sizeof(union FoobarUnion)];
        [self printUnionValueA:*(union FoobarUnion *)&d];
        
        ((void (*)(id,SEL,double))(objc_msgSend))(self, @selector(printUnionValueA:), d);
        
        typedef void (*FoobarImp)(id,SEL,double);
        Method method = class_getInstanceMethod(self.class, @selector(printUnionValueA:));
        FoobarImp imp = (FoobarImp)method_getImplementation(method);
        imp(self, @selector(printUnionValueA:), d);
        
        void *buffer = calloc(1, sizeof(double));
        [value getValue:buffer size:sizeof(union FoobarUnion)];
        [self printUnionValueA:*(union FoobarUnion *)buffer];
        
        ((void (*)(id,SEL,double))(objc_msgSend))(self, @selector(printUnionValueA:), *(double *)buffer);
        imp(self, @selector(printUnionValueA:), *(double *)buffer);
        
        double b = 0;
        union FoobarUnion c;
        memcpy(&b, buffer, sizeof(double));
        memcpy(&c, buffer, sizeof(union FoobarUnion));
        ((void (*)(id,SEL,double))(objc_msgSend))(self, @selector(printUnionValueA:), b);
        imp(self, @selector(printUnionValueA:), b);
        
        [self printUnionValueA:c];
        
        union FoobarUnion e;
        memcpy(&e, &b, sizeof(double));
        [self printUnionValueA:c];
        
        free(buffer);
    }
    {
        union FoobarUnion u;
        u.b = 200;
        NSValue *value = [NSValue valueWithBytes:&u objCType:@encode(union FoobarUnion)];
        
        double d = 0;
        [value getValue:&d size:sizeof(double)];
        ((void (*)(id,SEL,double))(objc_msgSend))(self, @selector(printUnionValueB:), d);
    }
}

- (void)printIntValue:(int)aValue {
    NSLog(@"%d", aValue);
}

- (void)printDoubleValue:(double)aValue {
    NSLog(@"%f", aValue);
}

- (void)printUnionValueA:(union FoobarUnion)aValue {
    NSLog(@"%d", aValue.a);
}

- (void)printUnionValueB:(union FoobarUnion)aValue {
    NSLog(@"%f", aValue.b);
}

- (void)testModelObserving {
    id model = @{
        @"name": @"John",
        @"age": @((NSInteger)20),
        @"from": @((CGFloat)10),
        @"to": @((float)30),
        @"rect": @(CGRectMake(10, 20, 30, 40))
    };
    XZMocoaTestsViewModel *viewModel = [[XZMocoaTestsViewModel alloc] initWithModel:model];
    [viewModel ready];
    NSLog(@"[viewModel ready]");
    
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"age", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"from", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"to", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"age", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"from", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"to", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"age", @"from", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"age", @"to", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"from", @"to", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"age", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"from", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"to", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"age", @"from", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"age", @"to", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"from", @"to", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"age", @"from", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"age", @"to", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"from", @"to", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"age", @"from", @"to", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"age", @"from", @"to", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"age", @"from", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"age", @"to", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"from", @"to", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"age", @"from", @"to", @"rect", nil]];
    [viewModel model:model didUpdateValuesForKeys:[NSSet setWithObjects:@"name", @"age", @"from", @"to", @"rect", nil]];
}

@end


@implementation XZMocoaTestsViewModel

+ (NSDictionary<NSString *,id> *)mappingModelKeys {
    return @{
        NSStringFromSelector(@selector(setName:)): @"name",
        NSStringFromSelector(@selector(setAge:)): @"age",
        NSStringFromSelector(@selector(setRect:)): @"rect",
        NSStringFromSelector(@selector(setFrom:to:)): @[@"from", @"to"],
    };
}

- (BOOL)shouldObserveModelKeysActively {
    return YES;
}

- (void)setName:(NSString *)name {
    NSLog(@"%s: %@", __FUNCTION__, name);
    XCTAssert([name isEqualToString:@"John"]);
}

- (void)setAge:(NSInteger)age {
    NSLog(@"%s: %ld", __FUNCTION__, age);
    XCTAssert(age == 20);
}

- (void)setFrom:(CGFloat)from to:(float)to {
    NSLog(@"%s: %f %f", __FUNCTION__, from, to);
    XCTAssert(from ==10);
}

- (void)setRect:(CGRect)rect {
    NSLog(@"%s: %@", __FUNCTION__, NSStringFromCGRect(rect));
    XCTAssert(CGRectEqualToRect(rect, CGRectMake(10, 20, 30, 40)));
}

- (void)valueChanged {
    
}

@end
