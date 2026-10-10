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
/// 仅通过公开 API（Foundation/UIKit 分类）验证解析行为；
/// XZMLParser 为内部实现（私有头文件），字体缩写注册表通过运行时调用。
@interface XZMLTests : XCTestCase
@end

@implementation XZMLTests

#pragma mark - 辅助方法

/// 指定范围内的第一个字符的属性字典。
- (NSDictionary *)attributesAtIndex:(NSUInteger)index ofString:(NSAttributedString *)string {
    XCTAssert(index < string.length, @"索引 %lu 超出范围 (%lu)", (unsigned long)index, (unsigned long)string.length);
    return [string attributesAtIndex:index effectiveRange:NULL];
}

/// 构造 XZML 富文本。
- (NSAttributedString *)attributedStringForXZML:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    return [[NSAttributedString alloc] initWithXZML:XZMLString attributes:attributes];
}

/// 注册字体缩写（XZMLParser 为私有类，通过运行时调用 +setFontName:forAbbreviation:）。
- (void)registerFontName:(NSString *)fontName forAbbreviation:(NSString *)abbreviation {
    Class parser = NSClassFromString(@"XZMLParser");
    XCTAssertNotNil(parser, @"XZMLParser 类不存在");
    ((void (*)(id, SEL, id, id))objc_msgSend)(parser, NSSelectorFromString(@"setFontName:forAbbreviation:"), fontName, abbreviation);
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
    XCTAssertEqualObjects([[NSMutableString alloc] initWithXZML:nil attributes:nil], @"");
    XCTAssertEqualObjects([[NSMutableString alloc] initWithXZML:@"" attributes:nil], @"");
    XCTAssertEqualObjects([[NSString alloc] initWithXZML:nil attributes:nil], @"");
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

/// 子元素层级超过 15 层后降级为纯文本（第 16 层内的样式标记不再解析）。
- (void)testDeepNestingLimit {
    NSMutableString *XZMLString = [NSMutableString string];
    // 17 层红色元素 + 第 18 层蓝色元素（超限，应作为普通文本）
    for (NSInteger i = 0; i < 17; i++) {
        [XZMLString appendString:@"<F00#"];
    }
    [XZMLString appendString:@"<00F#text"];
    for (NSInteger i = 0; i < 18; i++) {
        [XZMLString appendString:@">"];
    }
    NSAttributedString *string = [self attributedStringForXZML:XZMLString attributes:nil];
    XCTAssertEqualObjects(string.string, @"text");
    // 超层的蓝色元素样式不生效，文本沿用可解析层级的红色
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

/// 含未配对代理项的字符串（无法转换 UTF-8）降级为纯文本：内容不丢失（回归：曾整串丢弃）。
- (void)testUnpairedSurrogateFallsBackToPlainText {
    // 孤立代理项无法写成字面量，运行时构造 "A" + U+D800 + "B"
    unichar const chars[] = { 'A', 0xD800, 'B' };
    NSString *broken = [NSString stringWithCharacters:chars length:3];
    // 前置条件：该字符串无法转换为 UTF-8
    XCTAssertNil([broken dataUsingEncoding:NSUTF8StringEncoding]);

    XCTAssertEqualObjects([self attributedStringForXZML:broken attributes:nil].string, broken);
    // 纯文本 API 同样保留内容
    XCTAssertEqualObjects([[NSString alloc] initWithXZML:broken attributes:nil], broken);

    // 含元素标记的也整串保留（放弃样式）："<F00#red>" + U+D800
    unichar const elementChars[] = { '<', 'F', '0', '0', '#', 'r', 'e', 'd', '>', 0xD800 };
    NSString *element = [NSString stringWithCharacters:elementChars length:sizeof(elementChars) / sizeof(elementChars[0])];
    XCTAssertEqualObjects([self attributedStringForXZML:element attributes:nil].string, element);
}

/// 转义与还原往返：转义后的字符串解析应还原原文。
- (void)testEscapeRoundTrip {
    NSArray<NSString *> *samples = @[@"a<b", @"a>b", @"a&b", @"a#b", @"a$b", @"a*b", @"a~b", @"a^b", @"a@b", @"a\\b", @"<@#&$*~^>\\"];
    for (NSString *sample in samples) {
        NSString *escaped = sample.stringByEscapingXZMLReservedCharacters;
        XCTAssertEqualObjects([self attributedStringForXZML:escaped attributes:nil].string, sample, @"往返失败: %@", sample);
    }
}

#pragma mark - 保留字符集

/// 保留字符集覆盖所有样式标记符与转义符。
- (void)testReservedCharacterSet {
    NSCharacterSet *set = NSCharacterSet.XZMLReservedCharacterSet;
    for (NSUInteger i = 0; i < @"<@#&$*~^>\\".length; i++) {
        unichar c = [@"<@#&$*~^>\\" characterAtIndex:i];
        XCTAssertTrue([set characterIsMember:c], @"U+%04X 应为保留字符", c);
    }
}

/// 转义属性：仅保留字符被转义，多字节字符不受影响。
- (void)testStringByEscaping {
    XCTAssertEqualObjects(@"a<b".stringByEscapingXZMLReservedCharacters, @"a\\<b");
    XCTAssertEqualObjects(@"中文".stringByEscapingXZMLReservedCharacters, @"中文");
    XCTAssertEqualObjects(@"plain".stringByEscapingXZMLReservedCharacters, @"plain");
    XCTAssertEqualObjects(@"\\".stringByEscapingXZMLReservedCharacters, @"\\\\");
}

/// 追加自定义保留字符（全局生效，放在最后执行，避免污染其他用例）。
- (void)testZZAddXZMLCharactersInString {
    [NSCharacterSet addXZMLCharactersInString:@"§"];
    unichar section = [@"§" characterAtIndex:0];
    XCTAssertTrue([NSCharacterSet.XZMLReservedCharacterSet characterIsMember:section]);
    XCTAssertEqualObjects(@"a§b".stringByEscapingXZMLReservedCharacters, @"a\\§b");
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
    // 前景色@背景色
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<F00@00F#ab>" attributes:nil]];
    XCTAssertEqualObjects(NSStringFromUIColor(attributes[NSForegroundColorAttributeName]), @"#FF0000FF");
    XCTAssertEqualObjects(NSStringFromUIColor(attributes[NSBackgroundColorAttributeName]), @"#0000FFFF");
}

/// 颜色预设值：XZMLForegroundColorAttributeName。
- (void)testColorPresetValue {
    NSAttributedString *string = [self attributedStringForXZML:@"<@00F#x>" attributes:@{
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
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<Helvetica@20&x>" attributes:@{NSFontAttributeName: defaultFont}]];
    UIFont *font = attributes[NSFontAttributeName];
    XCTAssertEqualObjects(font.fontName, @"Helvetica");
    XCTAssertEqualWithAccuracy(font.pointSize, 20, 0.001);

    // 仅字号：空字体名 + 字号
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<@18&x>" attributes:@{NSFontAttributeName: defaultFont}]];
    font = attributes[NSFontAttributeName];
    XCTAssertEqualWithAccuracy(font.pointSize, 18, 0.001);

    // 基准线偏移
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<Helvetica@20@5&x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSBaselineOffsetAttributeName], @(5));

    // 不存在的字体名：使用默认字体字形 + 指定字号
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<NoSuchFontXZ@22&x>" attributes:@{NSFontAttributeName: defaultFont}]];
    font = attributes[NSFontAttributeName];
    XCTAssertEqualWithAccuracy(font.pointSize, 22, 0.001);
}

/// 字体预设值：XZMLFontAttributeName 决定字体名（默认子属性）。
- (void)testFontPresetValue {
    UIFont *preset = [UIFont fontWithName:@"Courier" size:11];
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<@30&x>" attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14],
        XZMLFontAttributeName: preset,
    }]];
    UIFont *font = attributes[NSFontAttributeName];
    XCTAssertEqualObjects(font.fontName, @"Courier");
    XCTAssertEqualWithAccuracy(font.pointSize, 30, 0.001);
}

/// 字体名缩写注册。
- (void)testFontAbbreviation {
    [self registerFontName:@"Courier" forAbbreviation:@"XZCR"];
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<XZCR@12&x>" attributes:nil]];
    XCTAssertEqualObjects(((UIFont *)attributes[NSFontAttributeName]).fontName, @"Courier");

    // 未注册的缩写按字体名处理，找不到时回退默认
    Class parser = NSClassFromString(@"XZMLParser");
    NSString *(*lookup)(id, SEL, id) = (void *)objc_msgSend;
    XCTAssertEqualObjects(lookup(parser, NSSelectorFromString(@"fontNameForAbbreviation:"), @"UnknownXZ"), @"UnknownXZ");
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
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<0@1$x>" attributes:nil]];
    XCTAssertEqualObjects(attributes[NSStrikethroughStyleAttributeName], @(NSUnderlineStyleDouble));

    // 粗下划线 + 颜色
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<1@2@F00$x>" attributes:nil]];
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
    XCTAssertEqualObjects([self attributedStringForXZML:@"<X@3*abc>" attributes:securityMode].string, @"XXX");
    XCTAssertEqualObjects([self attributedStringForXZML:@"<@2*abc>" attributes:securityMode].string, @"**");
    // 指定重复次数时忽略文本长度
    XCTAssertEqualObjects([self attributedStringForXZML:@"<@5*secret>" attributes:securityMode].string, @"*****");
}

/// 安全模式：极端重复次数被钳制到上限 64，避免构造超大字符串。
- (void)testSecurityRepeatLimit {
    NSDictionary *securityMode = @{XZMLSecurityModeAttributeName: @YES};
    NSString *expected = [@"" stringByPaddingToLength:64 withString:@"*" startingAtIndex:0];
    XCTAssertEqualObjects([self attributedStringForXZML:@"<@1000000000*abc>" attributes:securityMode].string, expected);
    // 未超限的重复次数不受影响
    XCTAssertEqualObjects([self attributedStringForXZML:@"<@64*abc>" attributes:securityMode].string, expected);
}

/// 安全模式：多字符替换符跳过子元素，重复 1 次。
- (void)testSecurityMultiCharacterMark {
    NSDictionary *securityMode = @{XZMLSecurityModeAttributeName: @YES};
    XCTAssertEqualObjects([self attributedStringForXZML:@"<AB*abc>" attributes:securityMode].string, @"AB");
    // 组合字符（emoji 代理对）视为单字符，按次数重复
    XCTAssertEqualObjects([self attributedStringForXZML:@"<😀@2*abc>" attributes:securityMode].string, @"😀😀");
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

#pragma mark - 段落样式（^）

- (void)testParagraphAttributes {
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<20H30M^x>" attributes:nil]];
    NSParagraphStyle *style = attributes[NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 20, 0.001);
    XCTAssertEqualWithAccuracy(style.maximumLineHeight, 30, 0.001);

    // 多倍行高
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<1.5X^x>" attributes:nil]];
    XCTAssertEqualWithAccuracy(((NSParagraphStyle *)attributes[NSParagraphStyleAttributeName]).lineHeightMultiple, 1.5, 0.001);

    // 对齐方式
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<1A^x>" attributes:nil]];
    XCTAssertEqual(((NSParagraphStyle *)attributes[NSParagraphStyleAttributeName]).alignment, NSTextAlignmentCenter);

    // 未指定标记符：默认最小行高
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<24^x>" attributes:nil]];
    XCTAssertEqualWithAccuracy(((NSParagraphStyle *)attributes[NSParagraphStyleAttributeName]).minimumLineHeight, 24, 0.001);

    // 首行缩进 + 行高组合
    attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<34F20X^x>" attributes:nil]];
    style = attributes[NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.firstLineHeadIndent, 34, 0.001);
    XCTAssertEqualWithAccuracy(style.lineHeightMultiple, 20, 0.001);
}

/// 行高预设值：XZMLLineHeightAttributeName。
- (void)testLineHeightPresetValue {
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<H^x>" attributes:@{
        XZMLLineHeightAttributeName: @26,
    }]];
    XCTAssertEqualWithAccuracy(((NSParagraphStyle *)attributes[NSParagraphStyleAttributeName]).minimumLineHeight, 26, 0.001);
}

/// attributes 中的段落默认样式应被合并保留。
- (void)testParagraphMergesDefaultStyle {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 5;
    NSDictionary *attributes = [self attributesAtIndex:0 ofString:[self attributedStringForXZML:@"<20H^x>" attributes:@{
        NSParagraphStyleAttributeName: paragraph,
    }]];
    NSParagraphStyle *style = attributes[NSParagraphStyleAttributeName];
    XCTAssertEqualWithAccuracy(style.lineSpacing, 5, 0.001);
    XCTAssertEqualWithAccuracy(style.minimumLineHeight, 20, 0.001);
}

#pragma mark - 纯文本（字符串）API

/// NSMutableString：只保留文本，丢弃样式标记。
- (void)testStringOnlyMode {
    XCTAssertEqualObjects([[NSMutableString alloc] initWithXZML:@"A <F00#B> C" attributes:nil], @"A B C");
    XCTAssertEqualObjects([[NSMutableString alloc] initWithXZML:@"<F00#红色>" attributes:nil], @"红色");
    XCTAssertEqualObjects([[NSString alloc] initWithXZML:@"<https://a.com/~链接>" attributes:nil], @"链接");
}

/// 纯文本模式下安全模式仍然生效。
- (void)testStringOnlySecurityMode {
    NSMutableString *string = [[NSMutableString alloc] initWithXZML:@"<*abc>" attributes:@{XZMLSecurityModeAttributeName: @YES}];
    XCTAssertEqualObjects(string, @"***");
}

/// 解析器多次调用状态不泄漏（回归：单例样式状态跨调用污染）。
- (void)testParserStateNotLeakedBetweenCalls {
    UILabel *label = [[UILabel alloc] init];
    UIFont *small = [UIFont systemFontOfSize:10];
    UIFont *large = [UIFont systemFontOfSize:20];
    [label setXZML:@"A" attributes:@{NSFontAttributeName: small}];
    [label setXZML:@"B" attributes:@{NSFontAttributeName: large}];
    XCTAssertEqualObjects([label.attributedText attributesAtIndex:0 effectiveRange:NULL][NSFontAttributeName], large, @"第二次调用不应沿用第一次的默认样式");
}

#pragma mark - UIKit 分类

- (void)testUILabelXZML {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColor.blueColor;
    [label setXZML:@"<F00#红>蓝"];
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
    [label setXZML:@"x" attributes:@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: UIColor.greenColor,
    }];
    NSDictionary *attributes = [label.attributedText attributesAtIndex:0 effectiveRange:NULL];
    XCTAssertEqualObjects(attributes[NSFontAttributeName], font);
}

/// nil XZML 不崩溃。
- (void)testUILabelNilXZML {
    UILabel *label = [[UILabel alloc] init];
    [label setXZML:nil attributes:nil];
    XCTAssertEqual(label.attributedText.length, 0U);
}

- (void)testUIButtonXZML {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setXZML:@"<F00#按钮>" forState:UIControlStateNormal];
    NSAttributedString *title = [button attributedTitleForState:UIControlStateNormal];
    XCTAssertEqualObjects(title.string, @"按钮");
    XCTAssertEqualObjects(NSStringFromUIColor([title attributesAtIndex:0 effectiveRange:NULL][NSForegroundColorAttributeName]), @"#FF0000FF");
}

- (void)testUITextViewXZML {
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:17];
    [textView setXZML:@"<B&文本>" attributes:nil];
    XCTAssertEqualObjects(textView.attributedText.string, @"文本");
}

- (void)testUITextFieldXZML {
    UITextField *textField = [[UITextField alloc] init];
    [textField setXZML:@"<F00#输入>" attributes:nil];
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
