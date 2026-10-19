//
//  XZMLTests.m
//  ExampleTests
//
//  Created by Xezun on 2026/10/10.
//

#import <XCTest/XCTest.h>
#import <objc/message.h>
@import XZKit;

/// XZML 全覆盖单元测试。
/// 仅通过公开 API（Foundation/UIKit 分类与 XZMLDefines 中的全局函数）验证解析行为。
@interface XZMLTests : XCTestCase
@end

@implementation XZMLTests {
    NSMutableDictionary *_abbreviations;
}

#pragma mark - 辅助方法

/// 指定范围内的第一个字符的属性字典。
- (NSDictionary *)attributesAtIndex:(NSUInteger)index ofString:(NSAttributedString *)string {
    if (index >= string.length) {
        // 越界时干净失败并返回空字典，避免直接走到 attributesAtIndex: 抛 NSRangeException 导致整个测试崩溃
        XCTFail(@"索引 %lu 超出范围 (长度 %lu)", (unsigned long)index, (unsigned long)string.length);
        return @{};
    }
    return [string attributesAtIndex:index effectiveRange:NULL];
}

/// 构造 XZML 富文本。
- (NSAttributedString *)attributedStringForXZML:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    return [[NSAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
}

/// 注册字体缩写。XZMLSetAbbreviations 是整体替换语义，此处先在实例内累加再提交。
- (void)registerFontName:(NSString *)fontName forAbbreviation:(NSString *)abbreviation {
    if (_abbreviations == nil) {
        _abbreviations = [NSMutableDictionary dictionary];
    }
    _abbreviations[abbreviation] = fontName;
    XZMLSetAbbreviations(_abbreviations);
}

#pragma mark - 基础语法

/// 纯文本 + 默认样式。
- (void)testPlainTextWithDefaultAttributes {
    UIFont *font = [UIFont systemFontOfSize:14];
    UIColor *color = UIColor.systemRedColor;
    NSAttributedString *string = [self attributedStringForXZML:@"Hello" attributes:@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: color,
    }];
    XCTAssertEqualObjects(string.string, @"Hello");
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:string];
    XCTAssertEqualObjects(attributes[NSFontAttributeName], font);
    XCTAssertEqualObjects(attributes[NSForegroundColorAttributeName], color);
}

/// nil 与空字符串输入。
- (void)testNilAndEmptyInput {
    XCTAssertEqual([[self attributedStringForXZML:nil attributes:nil] length], 0U);
    XCTAssertEqual([[self attributedStringForXZML:@"" attributes:nil] length], 0U);
    XCTAssertEqualObjects([[NSMutableString alloc] initWithXZMLString:nil attributes:nil], @"");
    XCTAssertEqualObjects([[NSMutableString alloc] initWithXZMLString:@"" attributes:nil], @"");
    XCTAssertEqualObjects([[NSString alloc] initWithXZMLString:nil attributes:nil], @"");
}

/// 空元素不产生文本。
- (void)testEmptyElement {
    NSAttributedString *string = [self attributedStringForXZML:@"<>" attributes:nil];
    XCTAssertEqualObjects(string.string, @"");
}

/// 元素与顶层文本串联。
- (void)testTopLevelMixedText {
    NSAttributedString *string = [self attributedStringForXZML:@"A <F00#B> C" attributes:nil];
    XCTAssertEqualObjects(string.string, @"A B C");
    XCTAssertNil([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName]);
    XCTAssertEqualObjects([self attributesAtIndex:2 ofString:string][NSForegroundColorAttributeName], UIColor.redColor);
    XCTAssertNil([self attributesAtIndex:4 ofString:string][NSForegroundColorAttributeName]);
}

/// 未闭合元素：已解析的样式和文本仍然生效。
- (void)testUnclosedElement {
    NSAttributedString *string = [self attributedStringForXZML:@"<F00#Red" attributes:nil];
    XCTAssertEqualObjects(string.string, @"Red");
    XCTAssertEqualObjects([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName], UIColor.redColor);
}

/// 末尾非 ASCII 字符：不应破坏 UTF-8 序列（回归：曾把终止符前一字节截断）。
- (void)testTrailingNonASCIICharacters {
    NSAttributedString *string = [self attributedStringForXZML:@"中文" attributes:nil];
    XCTAssertEqualObjects(string.string, @"中文");

    string = [self attributedStringForXZML:@"<F00#红色>" attributes:nil];
    XCTAssertEqualObjects(string.string, @"红色");
    XCTAssertEqualObjects([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName], UIColor.redColor);

    string = [self attributedStringForXZML:@"尾部是 中。" attributes:nil];
    XCTAssertEqualObjects(string.string, @"尾部是 中。");

    string = [self attributedStringForXZML:@"<F00#红" attributes:nil];
    XCTAssertEqualObjects(string.string, @"红");
}

/// 元素嵌套与样式继承。
- (void)testNestingAndStyleInheritance {
    NSAttributedString *string = [self attributedStringForXZML:@"<F00#a<00F#b>c>" attributes:nil];
    XCTAssertEqualObjects(string.string, @"abc");
    XCTAssertEqualObjects([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName], UIColor.redColor);
    XCTAssertEqualObjects([self attributesAtIndex:1 ofString:string][NSForegroundColorAttributeName], UIColor.blueColor);
    // 子元素结束后恢复父元素样式
    XCTAssertEqualObjects([self attributesAtIndex:2 ofString:string][NSForegroundColorAttributeName], UIColor.redColor);
}

/// 元素之后的顶层文本不继承元素样式。
- (void)testStyleNotLeakedAfterElement {
    NSAttributedString *string = [self attributedStringForXZML:@"<F00#Red>After" attributes:nil];
    XCTAssertEqualObjects(string.string, @"RedAfter");
    XCTAssertNil([self attributesAtIndex:3 ofString:string][NSForegroundColorAttributeName]);
}

/// 元素嵌套不设层级上限：深层样式正常继承，未闭合的深嵌套也不越界、不崩溃。
/// 回归：曾用定长数组 `XZMLReadingMode _modes[16]` 并有 16 层上限，第 17 层起越界写栈。
- (void)testDeepNestingWithoutLimit {
    // 20 层红色嵌套 + 第 21 层蓝色：无上限保护时，最深层的蓝色生效
    NSMutableString *XZMLString = [NSMutableString string];
    for (NSInteger i = 0; i < 20; i++) {
        [XZMLString appendString:@"<F00#"];
    }
    [XZMLString appendString:@"<00F#text"];
    for (NSInteger i = 0; i < 21; i++) {
        [XZMLString appendString:@">"];
    }
    NSAttributedString *string = [self attributedStringForXZML:XZMLString attributes:nil];
    XCTAssertEqualObjects(string.string, @"text");
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName]), @"#0000FFFF");

    // 1000 层未闭合的元素：模式栈动态增长，不越界写，文本正常输出并继承最深层样式
    NSMutableString *unclosed = [NSMutableString string];
    for (NSInteger i = 0; i < 1000; i++) {
        [unclosed appendString:@"<F00#"];
    }
    [unclosed appendString:@"text"];
    string = [self attributedStringForXZML:unclosed attributes:nil];
    XCTAssertEqualObjects(string.string, @"text");
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName]), @"#FF0000FF");
}

#pragma mark - 转义

/// 顶层转义：`\X` 输出原始字符 X。
- (void)testTopLevelEscaping {
    XCTAssertEqualObjects([self attributedStringForXZML:@"a\\<b" attributes:nil].string, @"a<b");
    // 行尾转义符被忽略
    XCTAssertEqualObjects([self attributedStringForXZML:@"abc\\" attributes:nil].string, @"abc");
    // 转义符自身
    XCTAssertEqualObjects([self attributedStringForXZML:@"a\\\\b" attributes:nil].string, @"a\\b");
}

/// 顶层未转义的裸 `>` 作为普通文本，不应终止解析（回归：曾导致其后内容整体丢失）。
- (void)testTopLevelUnescapedGreaterThan {
    XCTAssertEqualObjects([self attributedStringForXZML:@"a > b" attributes:nil].string, @"a > b");
    XCTAssertEqualObjects([self attributedStringForXZML:@">abc" attributes:nil].string, @">abc");
    XCTAssertEqualObjects([self attributedStringForXZML:@"A>B<C&x>D" attributes:nil].string, @"A>BxD");
    // 元素闭合后紧跟裸 '>'
    NSAttributedString *string = [self attributedStringForXZML:@"<F00#red>>tail" attributes:nil];
    XCTAssertEqualObjects(string.string, @"red>tail");
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName]), @"#FF0000FF");
    XCTAssertNil([self attributesAtIndex:4 ofString:string][NSForegroundColorAttributeName]);
}

/// 元素内转义：文本中的保留字符用 `\` 还原。
- (void)testElementTextEscaping {
    XCTAssertEqualObjects([self attributedStringForXZML:@"<F00#a\\>b>" attributes:nil].string, @"a>b");
    XCTAssertEqualObjects([self attributedStringForXZML:@"<F00#a\\<b>" attributes:nil].string, @"a<b");
    XCTAssertEqualObjects([self attributedStringForXZML:@"<F00#x\\>y>" attributes:nil].string, @"x>y");
}

/// 转义符后紧跟多字节字符：转义状态应在多字节字符处消费，元素正常闭合（回归：曾顺延至 '>' 导致串台/整段丢失）。
- (void)testEscapingBeforeNonASCII {
    // 元素内：`\<多字节>` 后元素应正常闭合，外层文本不受样式影响
    NSAttributedString *string = [self attributedStringForXZML:@"<F00#\\中>tail" attributes:nil];
    XCTAssertEqualObjects(string.string, @"中tail");
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName]), @"#FF0000FF");
    XCTAssertNil([self attributesAtIndex:1 ofString:string][NSForegroundColorAttributeName]);

    // 代理对（emoji）同理
    string = [self attributedStringForXZML:@"<F00#\\😀>x" attributes:nil];
    XCTAssertEqualObjects(string.string, @"😀x");

    // SkipElement 路径（Abort 扫描）：应在正确的 '>' 处结束，外层文本不丢失
    string = [self attributedStringForXZML:@"<AB*\\中>tail" attributes:@{XZMLSecurityModeAttributeName: @YES}];
    XCTAssertEqualObjects(string.string, @"ABtail");

    // TextOnly 路径（安全模式星号替代）：星号数量与文本字符数一致
    string = [self attributedStringForXZML:@"<*\\中>tail" attributes:@{XZMLSecurityModeAttributeName: @YES}];
    XCTAssertEqualObjects(string.string, @"*tail");
}

/// 含未配对代理项的字符串无法表示为 UTF-8，但词法解析按组合字符序列（而非 UTF-8 字节流）扫描，
/// 因此此类输入照常解析：代理项作为普通文本保留在结果中，元素样式也正常生效。
- (void)testUnpairedSurrogateIsParsed {
    // 孤立代理项无法写成字面量，运行时构造 "A" + U+D800 + "B"
    unichar const chars[] = { 'A', 0xD800, 'B' };
    NSString *broken = [NSString stringWithCharacters:chars length:3];
    // 前置条件：该字符串无法转换为 UTF-8
    XCTAssertNil([broken dataUsingEncoding:NSUTF8StringEncoding]);
    // 陷阱：canBeConvertedToEncoding: 对此类字符串仍返回 YES，不能用作可解析性判据
    XCTAssertTrue([broken canBeConvertedToEncoding:NSUTF8StringEncoding]);

    // 代理项不是 ASCII 字符，不会触发元素边界/样式/转义语义，直接作为普通文本输出
    NSAttributedString *string = [self attributedStringForXZML:broken attributes:nil];
    XCTAssertEqual(string.length, 3U);
    XCTAssertEqualObjects(string.string, broken);
    // 纯文本 API 同样保留代理项
    XCTAssertEqualObjects([[NSString alloc] initWithXZMLString:broken attributes:nil], broken);

    // 含元素标记的串也正常解析：元素样式生效，尾部的代理项作为普通文本保留
    unichar const elementChars[] = { '<', 'F', '0', '0', '#', 'r', 'e', 'd', '>', 0xD800 };
    NSString *element = [NSString stringWithCharacters:elementChars length:sizeof(elementChars) / sizeof(elementChars[0])];
    string = [self attributedStringForXZML:element attributes:nil];
    XCTAssertEqual(string.length, 4U);
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName]), @"#FF0000FF");

    // 对照：可正常转换 UTF-8 的字符串不受影响
    XCTAssertEqualObjects([self attributedStringForXZML:@"<F00#red>" attributes:nil].string, @"red");
}

/// 转义与还原往返：转义后的字符串解析应还原原文。
- (void)testEscapeRoundTrip {
    NSArray<NSString *> *samples = @[@"a<b", @"a>b", @"a&b", @"a#b", @"a$b", @"a*b", @"a~b", @"a|b", @"a@b", @"a:b", @"a\\b", @"<:#&$*~|>\\"];
    for (NSString *sample in samples) {
        NSString *escaped = sample.stringByAddingXZMLEscapes;
        XCTAssertEqualObjects([self attributedStringForXZML:escaped attributes:nil].string, sample, @"往返失败: %@", sample);
    }
}

#pragma mark - 保留字符集

/// 保留字符集覆盖所有样式标记符与转义符；子属性分隔符 `:` 不是保留字符。
- (void)testReservedCharacterSet {
    NSCharacterSet *set = NSCharacterSet.XZMLReservedCharacterSet;
    for (NSUInteger i = 0; i < @"<#&$*~|>\\".length; i++) {
        unichar c = [@"<#&$*~|>\\" characterAtIndex:i];
        XCTAssertTrue([set characterIsMember:c], @"U+%04X => %c 应为保留字符", c, (char)c);
    }
    // 分隔符仅在样式值区域生效，文本中的 `:` 无需转义
    XCTAssertFalse([set characterIsMember:':']);
}

/// 转义属性：仅保留字符被转义，多字节字符不受影响。
- (void)testStringByEscaping {
    XCTAssertEqualObjects(@"a<b".stringByAddingXZMLEscapes, @"a\\<b");
    XCTAssertEqualObjects(@"a:b".stringByAddingXZMLEscapes, @"a:b");
    XCTAssertEqualObjects(@"中文".stringByAddingXZMLEscapes, @"中文");
    XCTAssertEqualObjects(@"plain".stringByAddingXZMLEscapes, @"plain");
    XCTAssertEqualObjects(@"\\".stringByAddingXZMLEscapes, @"\\\\");
}

#pragma mark - 颜色样式（#）

- (void)testColorFormats {
    // RGB 三位缩写
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<D34#x>" attributes:nil]][NSForegroundColorAttributeName]), @"#DD3344FF");
    // RRGGBB
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<12BC89#x>" attributes:nil]][NSForegroundColorAttributeName]), @"#12BC89FF");
    // RGBA 四位缩写
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<D34B#x>" attributes:nil]][NSForegroundColorAttributeName]), @"#DD3344BB");
    // RRGGBBAA
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<12BC8955#x>" attributes:nil]][NSForegroundColorAttributeName]), @"#12BC8955");
    // 前景色:背景色
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<F00:00F#ab>" attributes:nil]];
    XCTAssertEqualObjects(NSStringFromUIColor(attributes[NSForegroundColorAttributeName]), @"#FF0000FF");
    XCTAssertEqualObjects(NSStringFromUIColor(attributes[NSBackgroundColorAttributeName]), @"#0000FFFF");
}

/// 颜色预设值：XZMLForegroundColorAttributeName。
- (void)testColorPresetValue {
    NSAttributedString *string = [self attributedStringForXZML:@"<:00F#x>" attributes:@{
        XZMLForegroundColorAttributeName: UIColor.greenColor,
    }];
    // 前景色使用预设值，背景色使用指定值
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName]), @"#00FF00FF");
    XCTAssertEqualObjects(NSStringFromUIColor([self attributesAtIndex:0 ofString:string][NSBackgroundColorAttributeName]), @"#0000FFFF");
}

/// 颜色默认值：attributes 中的 NS 键作为兜底，应用于顶层与元素文本。
- (void)testColorDefaultValue {
    NSAttributedString *string = [self attributedStringForXZML:@"ab<&y>" attributes:@{
        NSForegroundColorAttributeName: UIColor.grayColor,
    }];
    XCTAssertEqualObjects(string.string, @"aby");
    XCTAssertEqualObjects([self attributesAtIndex:0 ofString:string][NSForegroundColorAttributeName], UIColor.grayColor);
    XCTAssertEqualObjects([self attributesAtIndex:2 ofString:string][NSForegroundColorAttributeName], UIColor.grayColor);
}

/// 非法颜色值不崩溃。
- (void)testInvalidColorValue {
    NSAttributedString *string = [self attributedStringForXZML:@"<GGG#x>" attributes:nil];
    XCTAssertEqualObjects(string.string, @"x");
}

#pragma mark - 字体样式（&）

- (void)testFontSizeAndName {
    UIFont *defaultFont = [UIFont systemFontOfSize:14];
    // 指定字体名和字号
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<Helvetica:20&x>" attributes:@{NSFontAttributeName: defaultFont}]];
    UIFont *font = attributes[NSFontAttributeName];
    XCTAssertEqualObjects(font.fontName, @"Helvetica");
    XCTAssertEqualWithAccuracy(font.pointSize, 20, 0.001);

    // 仅字号：空字体名 + 字号
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<:18&x>" attributes:@{NSFontAttributeName: defaultFont}]];
    font = attributes[NSFontAttributeName];
    XCTAssertEqualWithAccuracy(font.pointSize, 18, 0.001);

    // 基准线偏移
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<Helvetica:20:5&x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSBaselineOffsetAttributeName], @(5));

    // 不存在的字体名：使用默认字体字形 + 指定字号
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<NoSuchFontXZ:22&x>" attributes:@{NSFontAttributeName: defaultFont}]];
    font = attributes[NSFontAttributeName];
    XCTAssertEqualWithAccuracy(font.pointSize, 22, 0.001);
}

/// 字体预设值：XZMLFontAttributeName 决定字体名（默认子属性）。
- (void)testFontPresetValue {
    UIFont *preset = [UIFont fontWithName:@"Courier" size:11];
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<:30&x>" attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14],
        XZMLFontAttributeName: preset,
    }]];
    UIFont *font = attributes[NSFontAttributeName];
    XCTAssertEqualObjects(font.fontName, @"Courier");
    XCTAssertEqualWithAccuracy(font.pointSize, 30, 0.001);
}

/// 字体名缩写注册。
/// 缩写表只包含显式注册过的键；未命中的名称直接作为字体名查找。
- (void)testFontAbbreviation {
    [self registerFontName:@"Courier" forAbbreviation:@"XZCR"];
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<XZCR:12&x>" attributes:nil]];
    XCTAssertEqualObjects(((UIFont *)attributes[NSFontAttributeName]).fontName, @"Courier");

    // getter 返回当前生效的缩写表，未注册的键不存在
    XCTAssertEqualObjects(XZMLGetAbbreviations()[@"XZCR"], @"Courier");
    XCTAssertNil(XZMLGetAbbreviations()[@"UnknownXZ"]);

    // 未注册缩写的真实字体名无需注册即可生效
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<Courier:12&x>" attributes:nil]];
    XCTAssertEqualObjects(((UIFont *)attributes[NSFontAttributeName]).fontName, @"Courier");

    // 注销缩写（fontName 传 nil 即移除该键），避免污染同一 target 内后续用例
    [self registerFontName:nil forAbbreviation:@"XZCR"];
    XCTAssertNil(XZMLGetAbbreviations()[@"XZCR"]);
}

#pragma mark - 文本修饰（$）

- (void)testDecorationTypes {
    // 默认删除线
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<$x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSStrikethroughStyleAttributeName], @(NSUnderlineStyleSingle));
    XCTAssertNil(attributes[NSUnderlineStyleAttributeName]);
    XCTAssertEqualObjects(attributes[NSBaselineOffsetAttributeName], @(0), @"iOS 10.3 兼容：删除线附带基准线偏移");

    // 下划线
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<1$x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSUnderlineStyleAttributeName], @(NSUnderlineStyleSingle));
    XCTAssertNil(attributes[NSStrikethroughStyleAttributeName]);

    // 双线删除线
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<0:1$x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSStrikethroughStyleAttributeName], @(NSUnderlineStyleDouble));

    // 粗下划线 + 颜色
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<1:2:F00$x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSUnderlineStyleAttributeName], @(NSUnderlineStyleThick));
    XCTAssertEqualObjects(NSStringFromUIColor(attributes[NSUnderlineColorAttributeName]), @"#FF0000FF");
}

/// 嵌套元素的下划线与删除线可共存（两个 `$`）。
- (void)testDecorationCoexist {
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<1$<0$x>>" attributes:nil]];
    XCTAssertNotNil(attributes[NSUnderlineStyleAttributeName]);
    XCTAssertNotNil(attributes[NSStrikethroughStyleAttributeName]);
}

/// 修饰预设值：XZMLDecorationAttributeName。
- (void)testDecorationPresetValue {
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<$x>" attributes:@{
        XZMLDecorationAttributeName: @(XZMLDecorationTypeUnderline),
    }]];
    XCTAssertNil(attributes[NSStrikethroughStyleAttributeName]);
    XCTAssertEqualObjects(attributes[NSUnderlineStyleAttributeName], @(NSUnderlineStyleSingle));
}

#pragma mark - 安全模式（*）

/// 非安全模式下 `*` 样式被忽略。
- (void)testSecurityIgnoredWithoutSecurityMode {
    NSAttributedString *string = [self attributedStringForXZML:@"<*abc>" attributes:nil];
    XCTAssertEqualObjects(string.string, @"abc");
}

/// 安全模式：默认替换符 `*`，重复次数与文本长度相同。
- (void)testSecurityDefaultMark {
    NSAttributedString *string = [self attributedStringForXZML:@"<*abc>" attributes:@{XZMLSecurityModeAttributeName: @YES}];
    XCTAssertEqualObjects(string.string, @"***");
}

/// 安全模式：自定义替换符与重复次数。
- (void)testSecurityMarkAndRepeat {
    NSDictionary *securityMode = @{XZMLSecurityModeAttributeName: @YES};
    XCTAssertEqualObjects([self attributedStringForXZML:@"<X:3*abc>" attributes:securityMode].string, @"XXX");
    XCTAssertEqualObjects([self attributedStringForXZML:@"<:2*abc>" attributes:securityMode].string, @"**");
    // 指定重复次数时忽略文本长度
    XCTAssertEqualObjects([self attributedStringForXZML:@"<:5*secret>" attributes:securityMode].string, @"*****");
}

/// 安全模式：极端重复次数被钳制到上限 64，避免构造超大字符串。
- (void)testSecurityRepeatLimit {
    NSDictionary *securityMode = @{XZMLSecurityModeAttributeName: @YES};
    NSString *expected = [@"" stringByPaddingToLength:64 withString:@"*" startingAtIndex:0];
    XCTAssertEqualObjects([self attributedStringForXZML:@"<:1000000000*abc>" attributes:securityMode].string, expected);
    // 未超限的重复次数不受影响
    XCTAssertEqualObjects([self attributedStringForXZML:@"<:64*abc>" attributes:securityMode].string, expected);
}

/// 安全模式的解析内部键（替代字符、重复次数）会保留在结果富文本的属性字典中。
/// 这两个键是解析器内部的私有键，仅供解析过程使用，不属于机密数据，
/// 也不属于 UIKit 认识的富文本属性，保留在属性字典中不影响渲染，因此不做过滤。
- (void)testSecurityInternalKeysRetainedInResult {
    NSAttributedString *string = [self attributedStringForXZML:@"<X:3*abc>" attributes:@{XZMLSecurityModeAttributeName: @YES}];
    XCTAssertEqualObjects(string.string, @"XXX");
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:string];
    XCTAssertEqualObjects(attributes[@"XZMLSecurityMarkAttributeName"], @"X");
    XCTAssertEqualObjects(attributes[@"XZMLSecurityRepeatAttributeName"], @(3));
    // 安全模式开关属于调用方入参，不会被写入解析结果
    XCTAssertNil(attributes[@"XZMLSecurityModeAttributeName"]);
}

/// 安全模式：多字符替换符跳过子元素，重复 1 次。
- (void)testSecurityMultiCharacterMark {
    NSDictionary *securityMode = @{XZMLSecurityModeAttributeName: @YES};
    XCTAssertEqualObjects([self attributedStringForXZML:@"<AB*abc>" attributes:securityMode].string, @"AB");
    // 组合字符（emoji 代理对）视为单字符，按次数重复
    XCTAssertEqualObjects([self attributedStringForXZML:@"<😀:2*abc>" attributes:securityMode].string, @"😀😀");
}

/// 安全模式忽略元素内子元素样式，仅统计文本。
- (void)testSecurityIgnoresSubElements {
    NSDictionary *securityMode = @{XZMLSecurityModeAttributeName: @YES};
    XCTAssertEqualObjects([self attributedStringForXZML:@"<*a<b&x>c>" attributes:securityMode].string, @"***");
}

#pragma mark - 超链接（~）

- (void)testLinkURL {
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<https://www.xezun.com/~x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSLinkAttributeName], [NSURL URLWithString:@"https://www.xezun.com/"]);

    // 文件路径
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"</tmp/a.txt~x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSLinkAttributeName], [NSURL fileURLWithPath:@"/tmp/a.txt"]);
}

/// 链接继承：子元素未指定链接时继承父元素。
- (void)testLinkInheritance {
    NSAttributedString *string = [self attributedStringForXZML:@"<https://www.xezun.com/~a<#b>c>" attributes:nil];
    NSURL *url = [NSURL URLWithString:@"https://www.xezun.com/"];
    XCTAssertEqualObjects([self attributesAtIndex:1 ofString:string][NSLinkAttributeName], url);
}

/// 链接预设值：XZMLLinkAttributeName。
- (void)testLinkPresetValue {
    NSURL *url = [NSURL URLWithString:@"https://www.xezun.com/"];
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<~x>" attributes:@{
        XZMLLinkAttributeName: url,
    }]];
    XCTAssertEqualObjects(attributes[NSLinkAttributeName], url);
}

#pragma mark - 段落样式（|）

- (void)testParagraphAttributes {
    // 行高：`最小行高-最大行高` 同时指定最小/最大行高
    NSParagraphStyle *style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<20-30|x>" attributes:nil]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 20, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 30, 0.001);

    // 行高不含 `-` 且无 `x` 前缀：按固定行距解析，min=max
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<1.5|x>" attributes:nil]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 1.5, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 1.5, 0.001);

    // 完整的 10 个位置字段
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<20-30:5:12:1:4:8:6:20:0:-1|x>" attributes:nil]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 20, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 30, 0.001);
    XCTAssertEqualWithAccuracy(style.lineSpacing, 5, 0.001);
    XCTAssertEqualWithAccuracy(style.firstLineHeadIndent, 12, 0.001);
    XCTAssertEqual(style.alignment, NSTextAlignmentCenter);
    XCTAssertEqual((NSInteger)style.lineBreakMode, (NSInteger)NSLineBreakByTruncatingTail);
    XCTAssertEqualWithAccuracy(style.paragraphSpacing, 8, 0.001);
    XCTAssertEqualWithAccuracy(style.paragraphSpacingBefore, 6, 0.001);
    XCTAssertEqualWithAccuracy(style.headIndent, 20, 0.001);
    XCTAssertEqualWithAccuracy(style.tailIndent, 0, 0.001);
    XCTAssertEqual(style.baseWritingDirection, NSWritingDirectionNatural);

    // 位置相关：前 4 个位段 行高:行间距:首行缩进:对齐方式
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<0:5:12:1|x>" attributes:nil]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.lineSpacing, 5, 0.001);
    XCTAssertEqualWithAccuracy(style.firstLineHeadIndent, 12, 0.001);
    XCTAssertEqual(style.alignment, NSTextAlignmentCenter);
    // 行高为 0：按固定行距写入 0（min=max=0），不写多倍行高
    XCTAssertEqualWithAccuracy(style.lineHeightMultiple, 0, 0.001);
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 0, 0.001);

    // 行高区间两端大小颠倒时不交换，按原样分别写入 min/max
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<30-20|x>" attributes:nil]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 30, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 20, 0.001);

    // 区间一侧为空：该侧不写入（保留默认 0），另一侧照常写入
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<30-|x>" attributes:nil]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.lineHeightMultiple, 0, 0.001);
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 30, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 0, 0.001);
    // `-5` 被当作区间：空起点不写入（min=0），终点写入 max=5
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<-5|x>" attributes:nil]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 0, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 5, 0.001);
    XCTAssertEqualWithAccuracy(style.lineHeightMultiple, 0, 0.001);

    // 只识别 10 个位段：多余的位段被丢弃，前 10 个属性照常生效
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<20-30:5:12:1:4:8:6:20:0:0:999:999|x>" attributes:nil]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 20, 0.001);
    XCTAssertEqualWithAccuracy(style.lineSpacing, 5, 0.001);
    XCTAssertEqual(style.alignment, NSTextAlignmentCenter);
    XCTAssertEqualWithAccuracy(style.tailIndent, 0, 0.001);
    XCTAssertEqual(style.baseWritingDirection, NSWritingDirectionLeftToRight);
}

/// 行高预设值：XZMLParagraphStyleAttributeName。
/// 仅当行高位段为空字符串时不写入，保留继承/预设行高；其余值按解析结果写入。
- (void)testLineHeightPresetValue {
    NSMutableParagraphStyle *preset = [[NSMutableParagraphStyle alloc] init];
    preset.minimumLineHeight = 26.0;
    preset.maximumLineHeight = 26.0;
    NSDictionary *attributes = @{XZMLParagraphStyleAttributeName: preset};

    // 行高位段留空（空字符串），仅指定位段 1（行间距）：保留预设行高
    NSParagraphStyle *style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<:5|x>" attributes:attributes]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 26, 0.001);
    XCTAssertEqualWithAccuracy(style.lineSpacing, 5, 0.001);

    // 固定行距：数字按 min=max 写入，会覆盖预设行高
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<20|x>" attributes:attributes]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 20, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 20, 0.001);

    // 多倍行高：`x` 前缀写入 lineHeightMultiple，不改动固定行高
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<x1.5|x>" attributes:attributes]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.lineHeightMultiple, 1.5, 0.001);
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 26, 0.001);

    // 区间一侧为空：有值侧覆盖，空值侧保留预设
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<30-|x>" attributes:attributes]][NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 30, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 26, 0.001);
}

/// attributes 中的段落默认样式应被合并保留。
- (void)testParagraphMergesDefaultStyle {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 5;
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<20-30|x>" attributes:@{
        NSParagraphStyleAttributeName: paragraph,
    }]];
    NSParagraphStyle *style = attributes[NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.lineSpacing, 5, 0.001);
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 20, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 30, 0.001);
}

/// 段落枚举位段的写入策略：`alignment` 原样写入、`lineBreakMode` 越界钳制为 TruncatingMiddle、`baseWritingDirection` 越界忽略。
- (void)testParagraphEnumValues {
    // 以一个与系统默认值完全不同的预设样式作为基准，使“越界忽略”可观察到
    NSMutableParagraphStyle *preset = [[NSMutableParagraphStyle alloc] init];
    preset.alignment            = NSTextAlignmentRight;
    preset.lineBreakMode        = NSLineBreakByClipping;
    preset.baseWritingDirection = NSWritingDirectionRightToLeft;
    NSDictionary *attributes = @{XZMLParagraphStyleAttributeName: preset};

    // alignment(9) 越界钳制为 NSTextAlignmentNatural
    // lineBreakMode (9) 越界钳制为 TruncatingMiddle
    // baseWritingDirection(9) 越界钳制为 NSWritingDirectionNatural
    NSParagraphStyle *style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<0:0:0:9:9:0:0:0:0:9|x>" attributes:attributes]][NSParagraphStyleAttributeName];
    XCTAssertEqual(style.alignment, NSTextAlignmentNatural);
    XCTAssertEqual((NSInteger)style.lineBreakMode, (NSInteger)NSLineBreakByTruncatingMiddle);
    XCTAssertEqual(style.baseWritingDirection, NSWritingDirectionNatural);

    // 负越界：alignment(-1) 原样写入（NSTextAlignment 为无符号位域存储，回读不等于预设）；baseWritingDirection(-2) 越界被忽略，沿用预设
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<0:0:0:-1:0:0:0:0:0:-2|x>" attributes:attributes]][NSParagraphStyleAttributeName];
    XCTAssertNotEqual(style.alignment, NSTextAlignmentRight);
    XCTAssertEqual(style.baseWritingDirection, NSWritingDirectionNatural);

    // 合法边界值：alignment(0)、lineBreakMode(5)、baseWritingDirection(0)
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<0:0:0:0:5:0:0:0:0:0|x>" attributes:attributes]][NSParagraphStyleAttributeName];
    XCTAssertEqual(style.alignment, NSTextAlignmentLeft);
    XCTAssertEqual((NSInteger)style.lineBreakMode, (NSInteger)NSLineBreakByTruncatingMiddle);
    XCTAssertEqual(style.baseWritingDirection, NSWritingDirectionLeftToRight);

    // 合法值：alignment(3 Justified)、lineBreakMode(3 TruncatingHead)、baseWritingDirection(-1 Natural)
    style = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<0:0:0:3:3:0:0:0:0:-1|x>" attributes:attributes]][NSParagraphStyleAttributeName];
    XCTAssertEqual(style.alignment, NSTextAlignmentJustified);
    XCTAssertEqual((NSInteger)style.lineBreakMode, (NSInteger)NSLineBreakByTruncatingHead);
    XCTAssertEqual(style.baseWritingDirection, NSWritingDirectionNatural);
}

#pragma mark - 纯文本（字符串）API

/// NSMutableString：只保留文本，丢弃样式标记。
- (void)testStringOnlyMode {
    XCTAssertEqualObjects([[NSMutableString alloc] initWithXZMLString:@"A <F00#B> C" attributes:nil], @"A B C");
    XCTAssertEqualObjects([[NSMutableString alloc] initWithXZMLString:@"<F00#红色>" attributes:nil], @"红色");
    XCTAssertEqualObjects([[NSString alloc] initWithXZMLString:@"<https://a.com/~链接>" attributes:nil], @"链接");
}

/// 纯文本模式下安全模式仍然生效。
- (void)testStringOnlySecurityMode {
    NSMutableString *string = [[NSMutableString alloc] initWithXZMLString:@"<*abc>" attributes:@{XZMLSecurityModeAttributeName: @YES}];
    XCTAssertEqualObjects(string, @"***");
}

/// 解析器多次调用状态不泄漏（回归：单例样式状态跨调用污染）。
- (void)testParserStateNotLeakedBetweenCalls {
    UILabel *label = [[UILabel alloc] init];
    UIFont *small = [UIFont systemFontOfSize:10];
    UIFont *large = [UIFont systemFontOfSize:20];
    [label setXZMLString:@"A" attributes:@{NSFontAttributeName: small}];
    [label setXZMLString:@"B" attributes:@{NSFontAttributeName: large}];
    XCTAssertEqualObjects([label.attributedText attributesAtIndex:0 effectiveRange:NULL][NSFontAttributeName], large, @"第二次调用不应沿用第一次的默认样式");
}

#pragma mark - UIKit 分类

- (void)testUILabelXZML {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColor.blueColor;
    [label setXZMLString:@"<F00#红>蓝"];
    XCTAssertEqualObjects(label.attributedText.string, @"红蓝");
    NSDictionary *attributes = [label.attributedText attributesAtIndex:0 effectiveRange:NULL];
    XCTAssertEqualObjects(NSStringFromUIColor(attributes[NSForegroundColorAttributeName]), @"#FF0000FF");
    XCTAssertEqualObjects([label.attributedText attributesAtIndex:1 effectiveRange:NULL][NSForegroundColorAttributeName], UIColor.blueColor);
    XCTAssertEqualObjects([label.attributedText attributesAtIndex:1 effectiveRange:NULL][NSFontAttributeName], label.font);
}

/// attributes 同时提供字体和颜色时，不使用控件默认值。
- (void)testUILabelXZMLWithFullAttributes {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16];
    UIFont *font = [UIFont systemFontOfSize:30];
    [label setXZMLString:@"x" attributes:@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: UIColor.greenColor,
    }];
    NSDictionary *attributes = [label.attributedText attributesAtIndex:0 effectiveRange:NULL];
    XCTAssertEqualObjects(attributes[NSFontAttributeName], font);
}

/// nil XZML 不崩溃。
- (void)testUILabelNilXZML {
    UILabel *label = [[UILabel alloc] init];
    [label setXZMLString:nil attributes:nil];
    XCTAssertEqual(label.attributedText.length, 0U);
}

- (void)testUIButtonXZML {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setXZMLString:@"<F00#按钮>" forState:UIControlStateNormal];
    NSAttributedString *title = [button attributedTitleForState:UIControlStateNormal];
    XCTAssertEqualObjects(title.string, @"按钮");
    XCTAssertEqualObjects(NSStringFromUIColor([title attributesAtIndex:0 effectiveRange:NULL][NSForegroundColorAttributeName]), @"#FF0000FF");
}

- (void)testUITextViewXZML {
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:17];
    [textView setXZMLString:@"<B&文本>" attributes:nil];
    XCTAssertEqualObjects(textView.attributedText.string, @"文本");
}

- (void)testUITextFieldXZML {
    UITextField *textField = [[UITextField alloc] init];
    [textField setXZMLString:@"<F00#输入>" attributes:nil];
    XCTAssertEqualObjects(textField.attributedText.string, @"输入");
}

#pragma mark - 默认属性中的 XZML 键过滤

/// XZML 预设键不应进入最终富文本属性。
- (void)testXZMLKeysFilteredFromResultAttributes {
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"x" attributes:@{
        XZMLFontAttributeName: [UIFont systemFontOfSize:20],
        XZMLForegroundColorAttributeName: UIColor.redColor,
    }]];
    XCTAssertNil(attributes[XZMLFontAttributeName]);
    XCTAssertNil(attributes[XZMLForegroundColorAttributeName]);
}

@end
