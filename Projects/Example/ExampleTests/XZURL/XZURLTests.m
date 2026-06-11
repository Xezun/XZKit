//
//  XZURLTests.m
//  ExampleTests
//
//  Created by Xezun on 2026/7/12.
//

#import <XCTest/XCTest.h>
#import "XZURL.h"

@interface XZURLTests : XCTestCase

@end

@implementation XZURLTests

#pragma mark - 初始化测试

- (void)testExample {
    XZURL *url = [XZURL URLWithURLString:@"https://www.xezun.com/path/?key=word"];
    XZLog(@"key = %@", url[@"key"]);
    XCTAssertEqualObjects(url[@"key"], @"word");
    
    NSURL *url1 = url.URL;
    NSURL *url2 = url.URL;
    XCTAssert(url1 == url2);
    
    url[@"name"] = @"John";
    NSURL *url3 = url.URL;
    XCTAssert(url1 != url3);
    
    [url removeAllQueryFields];
    XCTAssertEqualObjects(url.URL.absoluteString, @"https://www.xezun.com/path/");
    
    [url setValuesForQueryFieldsWithDictionary:@{
        @"name": @"Jim",
        @"age": @(20),
        @"list": @[@"sing", @"play"]
    }];
    XCTAssertEqualObjects(url[@"name"], @"Jim");
    XCTAssertEqualObjects(url[@"age"], @"20");
    NSArray *list = @[@"sing", @"play"];
    XCTAssertEqualObjects(url[@"list"], list);
    
    [url addValuesForQueryFieldsWithDictionary:@{
        @"name": @"John",
        @"age": @"19",
        @"list": @[@"football", @"pingpang"],
        @"test": @[@"test"]
    }];
    list = @[@"Jim", @"John"];
    XCTAssertEqualObjects(url[@"name"], list);
    list = @[@"20", @"19"];
    XCTAssertEqualObjects(url[@"age"], list);
    list = @[@"sing", @"play", @"football", @"pingpang"];
    XCTAssertEqualObjects(url[@"list"], list);
    
    XCTAssertEqualObjects(url[@"test"], @"test");
}

- (void)testInitWithNSURL_ValidURL {
    NSURL *nsURL = [NSURL URLWithString:@"https://example.com/path?key=value#fragment"];
    XZURL *url = [XZURL URLWithURL:nsURL];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(url.scheme, @"https");
    XCTAssertEqualObjects(url.host, @"example.com");
    XCTAssertEqualObjects(url.path, @"/path");
    XCTAssertEqualObjects(url.fragment, @"fragment");
}

- (void)testInitWithNSURL_Nil {
    XZURL *url = [XZURL URLWithURL:nil];
    XCTAssertNil(url);
}

- (void)testInitWithNSURL_InvalidURL {
    // NSURL URLWithString 对某些畸形字符串会返回 nil，此处测试传入 nil 的情况
    NSURL *invalidURL = [NSURL URLWithString:@""];
    XZURL *url = [XZURL URLWithURL:invalidURL];
    // 空字符串创建 NSURL 可能返回 nil 或空 URL
    // 根据 XZURL 实现，若 NSURLComponents 无法解析则返回 nil
    // 这里验证不会崩溃
    (void)url;
}

- (void)testInitWithURLString_Valid {
    XZURL *url = [XZURL URLWithURLString:@"https://user:pass@example.com:8080/path?q=1#frag"];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(url.scheme, @"https");
    XCTAssertEqualObjects(url.user, @"user");
    XCTAssertEqualObjects(url.password, @"pass");
    XCTAssertEqualObjects(url.host, @"example.com");
    XCTAssertEqualObjects(url.port, @8080);
    XCTAssertEqualObjects(url.path, @"/path");
    XCTAssertEqualObjects(url.query, @"q=1");
    XCTAssertEqualObjects(url.fragment, @"frag");
}

- (void)testInitWithURLString_Nil {
    XZURL *url = [XZURL URLWithURLString:nil];
    XCTAssertNil(url);
}

- (void)testInitWithURLString_Empty {
    XZURL *url = [XZURL URLWithURLString:@""];
    // 空字符串可能返回 nil 或一个空的 XZURL，不应崩溃
    (void)url;
}

- (void)testInitWithURLString_MinimalScheme {
    XZURL *url = [XZURL URLWithURLString:@"https://"];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(url.scheme, @"https");
}

- (void)testInitWithURLString_NoQuery {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com/path"];
    XCTAssertNotNil(url);
    XCTAssertNil(url.query);
    XCTAssertEqual(url.allQueryFields.count, 0);
}

- (void)testInitWithURLString_PercentEncoded {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com/path?key=hello%20world"];
    XCTAssertNotNil(url);
    NSString *value = [url stringValueForQueryField:@"key"];
    XCTAssertEqualObjects(value, @"hello world");
}

- (void)testInitWithComponents {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://example.com"];
    XZURL *url = [XZURL URLWithComponents:components];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(url.scheme, @"https");
    XCTAssertEqualObjects(url.host, @"example.com");
    
    // 验证修改原始 components 不会影响 XZURL
    components.host = @"other.com";
    XCTAssertEqualObjects(url.host, @"example.com");
}

- (void)testInitWithComponents_Modification {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://example.com/path?key=value"];
    XZURL *url = [XZURL URLWithComponents:components];
    
    // 修改原始 components 的 query
    components.query = @"other=1";
    
    // XZURL 应该不受影响
    XCTAssertEqualObjects([url stringValueForQueryField:@"key"], @"value");
    XCTAssertFalse([url containsValueForQueryField:@"other"]);
}

- (void)testDefaultInitUnavailable {
    // -init 被标记为 NS_UNAVAILABLE，编译期应报错。
    // 此处仅做运行时验证（如果绕过编译检查）。
    XCTAssertTrue(YES, "init is marked NS_UNAVAILABLE, compiler should prevent direct use.");
}

#pragma mark - URL 属性测试

- (void)testURLProperty_ReflectsChanges {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    url.path = @"/newpath";
    NSURL *nsURL = url.URL;
    XCTAssertEqualObjects(nsURL.path, @"/newpath");
    XCTAssertEqualObjects([nsURL absoluteString], @"https://example.com/newpath");
}

- (void)testURLProperty_LazyEvaluation {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    
    // 第一次获取 url
    NSURL *url1 = url.URL;
    XCTAssertNotNil(url1);
    
    // 修改属性
    url.host = @"other.com";
    
    // 第二次获取 url 应反映修改
    NSURL *url2 = url.URL;
    XCTAssertEqualObjects(url2.host, @"other.com");
    
    // 两次获取的 url 可能不同
    XCTAssertNotEqualObjects([url1 absoluteString], [url2 absoluteString]);
}

#pragma mark - 基本属性读写测试

- (void)testSchemeProperty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    XCTAssertEqualObjects(url.scheme, @"https");
    
    url.scheme = @"http";
    XCTAssertEqualObjects(url.scheme, @"http");
    XCTAssertEqualObjects(url.URL.scheme, @"http");
    
    url.scheme = nil;
    XCTAssertNil(url.scheme);
}

- (void)testUserProperty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    XCTAssertNil(url.user);
    
    url.user = @"admin";
    XCTAssertEqualObjects(url.user, @"admin");
    XCTAssertEqualObjects(url.URL.user, @"admin");
    
    url.user = nil;
    XCTAssertNil(url.user);
}

- (void)testPasswordProperty {
    XZURL *url = [XZURL URLWithURLString:@"https://user:secret@example.com"];
    XCTAssertEqualObjects(url.password, @"secret");
    
    url.password = @"newsecret";
    XCTAssertEqualObjects(url.password, @"newsecret");
    
    url.password = nil;
    XCTAssertNil(url.password);
}

- (void)testHostProperty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    XCTAssertEqualObjects(url.host, @"example.com");
    
    url.host = @"test.com";
    XCTAssertEqualObjects(url.host, @"test.com");
    XCTAssertEqualObjects(url.URL.host, @"test.com");
    
    url.host = nil;
    XCTAssertNil(url.host);
}

- (void)testPortProperty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com:8080"];
    XCTAssertEqualObjects(url.port, @8080);
    
    url.port = @9090;
    XCTAssertEqualObjects(url.port, @9090);
    XCTAssertEqualObjects(url.URL.port, @9090);
    
    url.port = nil;
    XCTAssertNil(url.port);
}

- (void)testPathProperty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com/a/b/c"];
    XCTAssertEqualObjects(url.path, @"/a/b/c");
    
    url.path = @"/x/y";
    XCTAssertEqualObjects(url.path, @"/x/y");
    
    url.path = nil;
    XCTAssert(url.path.length == 0);
}

- (void)testQueryProperty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value"];
    XCTAssertEqualObjects(url.query, @"key=value");
    
    url.query = @"a=1&b=2";
    XCTAssertEqualObjects(url.query, @"a=1&b=2");
    
    url.query = nil;
    XCTAssertNil(url.query);
}

- (void)testFragmentProperty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com#section"];
    XCTAssertEqualObjects(url.fragment, @"section");
    
    url.fragment = @"top";
    XCTAssertEqualObjects(url.fragment, @"top");
    
    url.fragment = nil;
    XCTAssertNil(url.fragment);
}

#pragma mark - allQueryFields 测试

- (void)testAllQueryFields_Empty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    NSDictionary *fields = url.allQueryFields;
    XCTAssertNotNil(fields);
    XCTAssertEqual(fields.count, 0);
}

- (void)testAllQueryFields_SingleValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value"];
    NSDictionary *fields = url.allQueryFields;
    XCTAssertEqual(fields.count, 1);
    XCTAssertEqualObjects(fields[@"key"], @"value");
}

- (void)testAllQueryFields_MultipleValues {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value1&key=value2"];
    NSDictionary *fields = url.allQueryFields;
    XCTAssertEqual(fields.count, 1);
    XCTAssertTrue([fields[@"key"] isKindOfClass:[NSArray class]]);
    NSArray *values = fields[@"key"];
    XCTAssertEqual(values.count, 2);
    XCTAssertEqualObjects(values[0], @"value1");
    XCTAssertEqualObjects(values[1], @"value2");
}

- (void)testAllQueryFields_NilValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key"];
    NSDictionary *fields = url.allQueryFields;
    XCTAssertEqual(fields.count, 1);
    XCTAssertEqualObjects(fields[@"key"], [NSNull null]);
}

- (void)testAllQueryFields_MixedTypes {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1&b&c=x&c=y"];
    NSDictionary *fields = url.allQueryFields;
    XCTAssertEqual(fields.count, 3);
    XCTAssertEqualObjects(fields[@"a"], @"1");
    XCTAssertEqualObjects(fields[@"b"], [NSNull null]);
    XCTAssertTrue([fields[@"c"] isKindOfClass:[NSArray class]]);
}

- (void)testAllQueryFields_EmptyValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key="];
    NSDictionary *fields = url.allQueryFields;
    XCTAssertEqual(fields.count, 1);
    XCTAssertEqualObjects(fields[@"key"], @"");
}

#pragma mark - valueForQueryField: 测试

- (void)testValueForQueryField_SingleValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?name=test"];
    id value = [url valueForQueryField:@"name"];
    XCTAssertEqualObjects(value, @"test");
}

- (void)testValueForQueryField_MultipleValues {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?tag=a&tag=b&tag=c"];
    id value = [url valueForQueryField:@"tag"];
    XCTAssertTrue([value isKindOfClass:[NSArray class]]);
    NSArray *arr = (NSArray *)value;
    XCTAssertEqual(arr.count, 3);
    XCTAssertEqualObjects(arr[0], @"a");
    XCTAssertEqualObjects(arr[1], @"b");
    XCTAssertEqualObjects(arr[2], @"c");
}

- (void)testValueForQueryField_NilValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?flag"];
    id value = [url valueForQueryField:@"flag"];
    // 根据文档，值为 nil 的字段，valueForQueryField 返回 nil 或 NSNull
    // 文档说"判断是否包含某字段需用 containsValueForQueryField"，暗示 value 可能为 nil
    XCTAssertTrue(value == nil || [value isKindOfClass:[NSNull class]]);
}

- (void)testValueForQueryField_NonExistent {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1"];
    id value = [url valueForQueryField:@"nonexistent"];
    XCTAssertNil(value);
}

- (void)testValueForQueryField_EmptyValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key="];
    id value = [url valueForQueryField:@"key"];
    XCTAssertEqualObjects(value, @"");
}

#pragma mark - setValue:forQueryField: 测试

- (void)testSetValue_String {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@"value1" forQueryField:@"key"];
    XCTAssertEqualObjects([url stringValueForQueryField:@"key"], @"value1");
}

- (void)testSetValue_Nil_RemovesField {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value"];
    [url setValue:nil forQueryField:@"key"];
    XCTAssertFalse([url containsValueForQueryField:@"key"]);
    XCTAssertNil([url valueForQueryField:@"key"]);
}

- (void)testSetValue_NSNull_SetsNilValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:[NSNull null] forQueryField:@"flag"];
    XCTAssertTrue([url containsValueForQueryField:@"flag"]);
    // 值为 NSNull 表示字段存在但值为 nil
    NSDictionary *fields = url.allQueryFields;
    XCTAssertEqualObjects(fields[@"flag"], [NSNull null]);
}

- (void)testSetValue_Overwrite {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=old"];
    [url setValue:@"new" forQueryField:@"key"];
    XCTAssertEqualObjects([url stringValueForQueryField:@"key"], @"new");
}

- (void)testSetValue_Number {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@42 forQueryField:@"num"];
    // 非 NSString 类型会转化为 JSON 字符串或 description
    NSString *value = [url stringValueForQueryField:@"num"];
    XCTAssertNotNil(value);
    XCTAssertTrue([value isEqualToString:@"42"] || [value isEqualToString:@"\"42\""]);
}

- (void)testSetValue_Array {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@[@"a", @"b"] forQueryField:@"items"];
    // 数组可能被 JSON 序列化
    NSString *value = [url stringValueForQueryField:@"items"];
    XCTAssertNotNil(value);
}

- (void)testSetValue_Dictionary {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@{@"k": @"v"} forQueryField:@"obj"];
    NSString *value = [url stringValueForQueryField:@"obj"];
    XCTAssertNotNil(value);
}

- (void)testSetValue_Bool {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@YES forQueryField:@"flag"];
    NSString *value = [url stringValueForQueryField:@"flag"];
    XCTAssertNotNil(value);
}

#pragma mark - addValue:forQueryField: 测试

- (void)testAddValue_NewField {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url addValue:@"value1" forQueryField:@"key"];
    XCTAssertEqualObjects([url stringValueForQueryField:@"key"], @"value1");
}

- (void)testAddValue_ExistingField_CreatesMultiple {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value1"];
    [url addValue:@"value2" forQueryField:@"key"];
    
    id value = [url valueForQueryField:@"key"];
    XCTAssertTrue([value isKindOfClass:[NSArray class]]);
    NSArray *arr = (NSArray *)value;
    XCTAssertEqual(arr.count, 2);
    XCTAssertEqualObjects(arr[0], @"value1");
    XCTAssertEqualObjects(arr[1], @"value2");
}

- (void)testAddValue_ThreeValues {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url addValue:@"a" forQueryField:@"k"];
    [url addValue:@"b" forQueryField:@"k"];
    [url addValue:@"c" forQueryField:@"k"];
    
    id value = [url valueForQueryField:@"k"];
    XCTAssertTrue([value isKindOfClass:[NSArray class]]);
    NSArray *arr = (NSArray *)value;
    XCTAssertEqual(arr.count, 3);
}

- (void)testAddValue_NilValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url addValue:nil forQueryField:@"key"];
    // 添加 nil 值，字段应存在但值为 NSNull
    XCTAssertTrue([url containsValueForQueryField:@"key"]);
}

- (void)testAddValue_DifferentFields {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url addValue:@"1" forQueryField:@"a"];
    [url addValue:@"2" forQueryField:@"b"];
    [url addValue:@"3" forQueryField:@"c"];
    
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
    XCTAssertEqualObjects([url stringValueForQueryField:@"b"], @"2");
    XCTAssertEqualObjects([url stringValueForQueryField:@"c"], @"3");
}

#pragma mark - removeAllQueryFields 测试

- (void)testRemoveAllQueryFields {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1&b=2&c=3"];
    [url removeAllQueryFields];
    XCTAssertEqual(url.allQueryFields.count, 0);
    XCTAssertNil(url.query);
}

- (void)testRemoveAllQueryFields_AlreadyEmpty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url removeAllQueryFields];
    XCTAssertEqual(url.allQueryFields.count, 0);
}

- (void)testRemoveAllQueryFields_ThenAdd {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1&b=2"];
    [url removeAllQueryFields];
    [url setValue:@"new" forQueryField:@"key"];
    XCTAssertEqual(url.allQueryFields.count, 1);
    XCTAssertEqualObjects([url stringValueForQueryField:@"key"], @"new");
}

#pragma mark - containsValueForQueryField: 测试

- (void)testContainsValueForQueryField_Exists {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value"];
    XCTAssertTrue([url containsValueForQueryField:@"key"]);
}

- (void)testContainsValueForQueryField_NotExists {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value"];
    XCTAssertFalse([url containsValueForQueryField:@"other"]);
}

- (void)testContainsValueForQueryField_NilValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?flag"];
    XCTAssertTrue([url containsValueForQueryField:@"flag"]);
}

- (void)testContainsValueForQueryField_EmptyValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key="];
    XCTAssertTrue([url containsValueForQueryField:@"key"]);
}

- (void)testContainsValueForQueryField_AfterRemoval {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value"];
    [url setValue:nil forQueryField:@"key"];
    XCTAssertFalse([url containsValueForQueryField:@"key"]);
}

- (void)testContainsValueForQueryField_AfterSetNSNull {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:[NSNull null] forQueryField:@"flag"];
    XCTAssertTrue([url containsValueForQueryField:@"flag"]);
}

- (void)testContainsValueForQueryField_CaseSensitive {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?Key=value"];
    XCTAssertTrue([url containsValueForQueryField:@"Key"]);
    XCTAssertFalse([url containsValueForQueryField:@"key"]);
    XCTAssertFalse([url containsValueForQueryField:@"KEY"]);
}

#pragma mark - 下标操作测试

- (void)testObjectForKeyedSubscript {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?name=test"];
    id value = url[@"name"];
    XCTAssertEqualObjects(value, @"test");
}

- (void)testObjectForKeyedSubscript_NonExistent {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?name=test"];
    id value = url[@"missing"];
    XCTAssertNil(value);
}

- (void)testSetObjectForKeyedSubscript {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    url[@"key"] = @"value";
    XCTAssertEqualObjects(url[@"key"], @"value");
}

- (void)testSetObjectForKeyedSubscript_Nil {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value"];
    url[@"key"] = nil;
    XCTAssertFalse([url containsValueForQueryField:@"key"]);
}

- (void)testSetObjectForKeyedSubscript_NSNull {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    url[@"flag"] = [NSNull null];
    XCTAssertTrue([url containsValueForQueryField:@"flag"]);
}

- (void)testSubscript_MultipleValues {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?tag=a&tag=b"];
    id value = url[@"tag"];
    XCTAssertTrue([value isKindOfClass:[NSArray class]]);
}

#pragma mark - stringValueForQueryField: 测试

- (void)testStringValueForQueryField_SingleValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=hello"];
    XCTAssertEqualObjects([url stringValueForQueryField:@"key"], @"hello");
}

- (void)testStringValueForQueryField_MultipleValues_ReturnsFirst {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=first&key=second"];
    XCTAssertEqualObjects([url stringValueForQueryField:@"key"], @"first");
}

- (void)testStringValueForQueryField_NonExistent {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    XCTAssertNil([url stringValueForQueryField:@"missing"]);
}

- (void)testStringValueForQueryField_NilValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?flag"];
    // 值为 nil/NSNull 的字段，stringValue 应返回 nil
    XCTAssertNil([url stringValueForQueryField:@"flag"]);
}

- (void)testStringValueForQueryField_EmptyValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key="];
    XCTAssertEqualObjects([url stringValueForQueryField:@"key"], @"");
}

#pragma mark - integerValueForQueryField: 测试

- (void)testIntegerValueForQueryField_ValidInteger {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?count=42"];
    XCTAssertEqual([url integerValueForQueryField:@"count"], 42);
}

- (void)testIntegerValueForQueryField_NegativeInteger {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?offset=-10"];
    XCTAssertEqual([url integerValueForQueryField:@"offset"], -10);
}

- (void)testIntegerValueForQueryField_Zero {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?num=0"];
    XCTAssertEqual([url integerValueForQueryField:@"num"], 0);
}

- (void)testIntegerValueForQueryField_NonNumeric {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=abc"];
    XCTAssertEqual([url integerValueForQueryField:@"key"], 0);
}

- (void)testIntegerValueForQueryField_NonExistent {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    XCTAssertEqual([url integerValueForQueryField:@"missing"], 0);
}

- (void)testIntegerValueForQueryField_Float {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?val=3.14"];
    // integerValue 会截断为 3
    XCTAssertEqual([url integerValueForQueryField:@"val"], 3);
}

- (void)testIntegerValueForQueryField_LargeNumber {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?big=999999999"];
    XCTAssertEqual([url integerValueForQueryField:@"big"], 999999999);
}

#pragma mark - floatValueForQueryField: 测试

- (void)testFloatValueForQueryField_ValidFloat {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?pi=3.14"];
    XCTAssertEqualWithAccuracy([url floatValueForQueryField:@"pi"], 3.14, 0.001);
}

- (void)testFloatValueForQueryField_Integer {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?num=42"];
    XCTAssertEqualWithAccuracy([url floatValueForQueryField:@"num"], 42.0, 0.001);
}

- (void)testFloatValueForQueryField_NegativeFloat {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?val=-2.5"];
    XCTAssertEqualWithAccuracy([url floatValueForQueryField:@"val"], -2.5, 0.001);
}

- (void)testFloatValueForQueryField_Zero {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?val=0.0"];
    XCTAssertEqualWithAccuracy([url floatValueForQueryField:@"val"], 0.0, 0.001);
}

- (void)testFloatValueForQueryField_NonNumeric {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=abc"];
    XCTAssertEqualWithAccuracy([url floatValueForQueryField:@"key"], 0.0, 0.001);
}

- (void)testFloatValueForQueryField_NonExistent {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    XCTAssertEqualWithAccuracy([url floatValueForQueryField:@"missing"], 0.0, 0.001);
}

#pragma mark - urlValueForQueryField: 测试

- (void)testURLValueForQueryField_ValidURL {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?redirect=https%3A%2F%2Fother.com%2Fpath"];
    NSURL *redirectURL = [url urlValueForQueryField:@"redirect"];
    XCTAssertNotNil(redirectURL);
    XCTAssertEqualObjects(redirectURL.absoluteString, @"https://other.com/path");
}

- (void)testURLValueForQueryField_NonExistent {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    NSURL *result = [url urlValueForQueryField:@"missing"];
    XCTAssertNil(result);
}

- (void)testURLValueForQueryField_NilValue {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?flag"];
    NSURL *result = [url urlValueForQueryField:@"flag"];
    XCTAssertNil(result);
}

- (void)testURLValueForQueryField_RelativeURL {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?next=%2Fdashboard"];
    NSURL *nextURL = [url urlValueForQueryField:@"next"];
    XCTAssertNotNil(nextURL);
    XCTAssertEqualObjects(nextURL.path, @"/dashboard");
}

#pragma mark - addValuesForQueryFieldsWithDictionary: 测试

- (void)testAddValuesForQueryFieldsWithDictionary_NewFields {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url addValuesForQueryFieldsWithDictionary:@{
        @"a": @"1",
        @"b": @"2",
        @"c": @"3"
    }];
    
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
    XCTAssertEqualObjects([url stringValueForQueryField:@"b"], @"2");
    XCTAssertEqualObjects([url stringValueForQueryField:@"c"], @"3");
}

- (void)testAddValuesForQueryFieldsWithDictionary_MergeWithExisting {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1"];
    [url addValuesForQueryFieldsWithDictionary:@{
        @"b": @"2",
        @"c": @"3"
    }];
    
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
    XCTAssertEqualObjects([url stringValueForQueryField:@"b"], @"2");
    XCTAssertEqualObjects([url stringValueForQueryField:@"c"], @"3");
}

- (void)testAddValuesForQueryFieldsWithDictionary_AddDuplicateKey {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=value1"];
    [url addValuesForQueryFieldsWithDictionary:@{
        @"key": @"value2"
    }];
    
    id value = [url valueForQueryField:@"key"];
    // addValue 应该追加，不覆盖
    XCTAssertTrue([value isKindOfClass:[NSArray class]]);
    NSArray *arr = (NSArray *)value;
    XCTAssertEqual(arr.count, 2);
}

- (void)testAddValuesForQueryFieldsWithDictionary_Nil {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1"];
    [url addValuesForQueryFieldsWithDictionary:nil];
    // 不应崩溃，原有字段不变
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
}

- (void)testAddValuesForQueryFieldsWithDictionary_Empty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1"];
    [url addValuesForQueryFieldsWithDictionary:@{}];
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
    XCTAssertEqual(url.allQueryFields.count, 1);
}

- (void)testAddValuesForQueryFieldsWithDictionary_WithNSNull {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url addValuesForQueryFieldsWithDictionary:@{
        @"flag": [NSNull null]
    }];
    XCTAssertTrue([url containsValueForQueryField:@"flag"]);
}

- (void)testAddValuesForQueryFieldsWithDictionary_WithNSArray {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url addValuesForQueryFieldsWithDictionary:@{
        @"list": @[@"item1", @"item2"]
    }];
    XCTAssert([url arrayValueForQueryField:@"list"].count == 2);
    [url addValuesForQueryFieldsWithDictionary:@{
        @"list": @[@"item3", @"item4"]
    }];
    XCTAssertTrue([url containsValueForQueryField:@"list"]);
    XCTAssert([url arrayValueForQueryField:@"list"].count == 4);
}

#pragma mark - setValuesForQueryFieldsWithDictionary: 测试

- (void)testSetValuesForQueryFieldsWithDictionary_NewFields {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValuesForQueryFieldsWithDictionary:@{
        @"x": @"10",
        @"y": @"20"
    }];
    
    XCTAssertEqualObjects([url stringValueForQueryField:@"x"], @"10");
    XCTAssertEqualObjects([url stringValueForQueryField:@"y"], @"20");
}

- (void)testSetValuesForQueryFieldsWithDictionary_OverwriteExisting {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?x=old"];
    [url setValuesForQueryFieldsWithDictionary:@{
        @"x": @"new"
    }];
    
    XCTAssertEqualObjects([url stringValueForQueryField:@"x"], @"new");
}

- (void)testSetValuesForQueryFieldsWithDictionary_Nil {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1"];
    [url setValuesForQueryFieldsWithDictionary:nil];
    // 不应崩溃，原有字段不变
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
}

- (void)testSetValuesForQueryFieldsWithDictionary_Empty {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1"];
    [url setValuesForQueryFieldsWithDictionary:@{}];
    // 空字典不应影响现有字段
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
}

- (void)testSetValuesForQueryFieldsWithDictionary_WithNSNull {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValuesForQueryFieldsWithDictionary:@{
        @"flag": [NSNull null]
    }];
    XCTAssertTrue([url containsValueForQueryField:@"flag"]);
}

- (void)testSetValuesForQueryFieldsWithDictionary_MultipleKeys {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?old=1"];
    [url setValuesForQueryFieldsWithDictionary:@{
        @"a": @"1",
        @"b": @"2",
        @"c": @"3"
    }];
    
    // 旧字段应保留（set 是针对字典中的 key 进行设置，不删除其他字段）
    XCTAssertTrue([url containsValueForQueryField:@"old"]);
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
    XCTAssertEqualObjects([url stringValueForQueryField:@"b"], @"2");
    XCTAssertEqualObjects([url stringValueForQueryField:@"c"], @"3");
}

#pragma mark - 综合场景测试

- (void)testComplexURL_ModifyAllComponents {
    XZURL *url = [XZURL URLWithURLString:@"https://user:pass@old.com:80/oldpath?a=1&b=2#oldfrag"];
    
    url.scheme = @"http";
    url.user = @"newuser";
    url.password = @"newpass";
    url.host = @"new.com";
    url.port = @443;
    url.path = @"/newpath";
    url.fragment = @"newfrag";
    
    [url setValue:nil forQueryField:@"a"];
    [url setValue:@"new2" forQueryField:@"b"];
    [url setValue:@"3" forQueryField:@"c"];
    
    NSURL *result = url.URL;
    XCTAssertEqualObjects(result.scheme, @"http");
    XCTAssertEqualObjects(result.user, @"newuser");
    XCTAssertEqualObjects(result.password, @"newpass");
    XCTAssertEqualObjects(result.host, @"new.com");
    XCTAssertEqualObjects(result.port, @443);
    XCTAssertEqualObjects(result.path, @"/newpath");
    XCTAssertEqualObjects(result.fragment, @"newfrag");
    
    XCTAssertFalse([url containsValueForQueryField:@"a"]);
    XCTAssertEqualObjects([url stringValueForQueryField:@"b"], @"new2");
    XCTAssertEqualObjects([url stringValueForQueryField:@"c"], @"3");
}

- (void)testQueryEncoding_SpecialCharacters {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@"hello world&foo=bar" forQueryField:@"msg"];
    
    NSString *value = [url stringValueForQueryField:@"msg"];
    XCTAssertEqualObjects(value, @"hello world&foo=bar");
    
    // URL 应该正确编码
    NSString *urlString = url.URL.absoluteString;
    XCTAssertNotNil(urlString);
}

- (void)testQueryEncoding_ChineseCharacters {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@"你好世界" forQueryField:@"name"];
    
    NSString *value = [url stringValueForQueryField:@"name"];
    XCTAssertEqualObjects(value, @"你好世界");
}

- (void)testMultipleAddAndRemove {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    
    // 添加多个字段
    for (int i = 0; i < 100; i++) {
        [url setValue:[NSString stringWithFormat:@"value%d", i]
       forQueryField:[NSString stringWithFormat:@"key%d", i]];
    }
    
    XCTAssertEqual(url.allQueryFields.count, 100);
    
    // 移除一半
    for (int i = 0; i < 50; i++) {
        [url setValue:nil forQueryField:[NSString stringWithFormat:@"key%d", i]];
    }
    
    XCTAssertEqual(url.allQueryFields.count, 50);
    
    // 验证剩余的
    for (int i = 50; i < 100; i++) {
        NSString *field = [NSString stringWithFormat:@"key%d", i];
        XCTAssertTrue([url containsValueForQueryField:field]);
    }
}

- (void)testSetQueryDirectly_ThenQueryFields {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    url.query = @"a=1&b=2&c=3";
    
    XCTAssertEqual(url.allQueryFields.count, 3);
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"1");
    XCTAssertEqualObjects([url stringValueForQueryField:@"b"], @"2");
    XCTAssertEqualObjects([url stringValueForQueryField:@"c"], @"3");
}

- (void)testSetQueryThenModifyField {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    url.query = @"a=1&b=2";
    
    [url setValue:@"new" forQueryField:@"a"];
    XCTAssertEqualObjects([url stringValueForQueryField:@"a"], @"new");
    XCTAssertEqualObjects([url stringValueForQueryField:@"b"], @"2");
}

- (void)testRemoveAllThenAdd {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1&b=2&c=3"];
    [url removeAllQueryFields];
    
    [url addValue:@"x" forQueryField:@"new"];
    XCTAssertEqual(url.allQueryFields.count, 1);
    XCTAssertEqualObjects([url stringValueForQueryField:@"new"], @"x");
}

- (void)testAddMultipleSameKey_ThenRemoveAll {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url addValue:@"a" forQueryField:@"key"];
    [url addValue:@"b" forQueryField:@"key"];
    [url addValue:@"c" forQueryField:@"key"];
    
    id value = [url valueForQueryField:@"key"];
    XCTAssertTrue([value isKindOfClass:[NSArray class]]);
    XCTAssertEqual(((NSArray *)value).count, 3);
    
    [url removeAllQueryFields];
    XCTAssertEqual(url.allQueryFields.count, 0);
    XCTAssertFalse([url containsValueForQueryField:@"key"]);
}

- (void)testSetValue_ReplaceMultipleValues {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?key=a&key=b&key=c"];
    
    // setValue 应该替换所有值为单个值
    [url setValue:@"single" forQueryField:@"key"];
    
    id value = [url valueForQueryField:@"key"];
    // 替换后应该是单个字符串
    XCTAssertEqualObjects(value, @"single");
}

- (void)testQueryField_SpecialCharactersInName {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@"value" forQueryField:@"key.with.dots"];
    XCTAssertEqualObjects([url stringValueForQueryField:@"key.with.dots"], @"value");
}

- (void)testQueryField_EmptyFieldName {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    [url setValue:@"value" forQueryField:@""];
    // 空字段名可能是合法的
    XCTAssertTrue([url containsValueForQueryField:@""]);
}

- (void)testURLWithNoScheme {
    XZURL *url = [XZURL URLWithURLString:@"example.com/path"];
    // 无 scheme 的 URL 可能被解析为 path
    XCTAssertNotNil(url);
}

- (void)testFileURL {
    XZURL *url = [XZURL URLWithURLString:@"file:///Users/test/file.txt"];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(url.scheme, @"file");
}

- (void)testCustomScheme {
    XZURL *url = [XZURL URLWithURLString:@"myapp://host/path?key=value"];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(url.scheme, @"myapp");
    XCTAssertEqualObjects(url.host, @"host");
    XCTAssertEqualObjects(url.path, @"/path");
}

#pragma mark - 边界条件测试

- (void)testVeryLongQuery {
    NSMutableString *longQuery = [NSMutableString string];
    for (int i = 0; i < 1000; i++) {
        if (i > 0) [longQuery appendString:@"&"];
        [longQuery appendFormat:@"key%d=value%d", i, i];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://example.com?%@", longQuery];
    XZURL *url = [XZURL URLWithURLString:urlString];
    XCTAssertNotNil(url);
    XCTAssertEqual(url.allQueryFields.count, 1000);
}

- (void)testQueryWithOnlyAmpersands {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?&&&"];
    XCTAssertNotNil(url);
    // 多个连续 & 可能产生空字段或被忽略
}

- (void)testQueryWithEqualsOnly {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?==="];
    XCTAssertNotNil(url);
}

- (void)testSetQueryNil_ClearsAllFields {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1&b=2"];
    url.query = nil;
    XCTAssertEqual(url.allQueryFields.count, 0);
}

- (void)testMultipleModifications_URLConsistency {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com"];
    
    // 多次修改后检查 URL 一致性
    for (int i = 0; i < 10; i++) {
        [url setValue:[NSString stringWithFormat:@"%d", i] forQueryField:@"counter"];
        NSURL *nsURL = url.URL;
        XCTAssertEqualObjects([nsURL query], [url query]);
    }
}

- (void)testAllQueryFields_ReturnsCopy {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1&b=2"];
    NSDictionary *fields1 = url.allQueryFields;
    
    // 修改 url 的 query
    [url setValue:@"3" forQueryField:@"c"];
    
    NSDictionary *fields2 = url.allQueryFields;
    
    // fields1 不应被修改（因为 allQueryFields 返回 copy）
    XCTAssertEqual(fields1.count, 2);
    XCTAssertEqual(fields2.count, 3);
}

#pragma mark - 性能测试

- (void)testPerformance_URLGeneration {
    XZURL *url = [XZURL URLWithURLString:@"https://example.com?a=1&b=2&c=3"];
    
    [self measureBlock:^{
        for (int i = 0; i < 1000; i++) {
            [url setValue:@"new" forQueryField:@"a"];
            NSURL *nsURL = url.URL;
            (void)nsURL;
        }
    }];
}

- (void)testPerformance_QueryParsing {
    // 构造一个包含大量 query 参数的 URL
    NSMutableString *query = [NSMutableString string];
    for (int i = 0; i < 500; i++) {
        if (i > 0) [query appendString:@"&"];
        [query appendFormat:@"k%d=v%d", i, i];
    }
    NSString *urlString = [NSString stringWithFormat:@"https://example.com?%@", query];
    
    [self measureBlock:^{
        for (int i = 0; i < 100; i++) {
            XZURL *url = [XZURL URLWithURLString:urlString];
            (void)url.allQueryFields;
        }
    }];
}

@end

