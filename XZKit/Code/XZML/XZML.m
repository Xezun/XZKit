//
//  XZML.m
//  XZML
//
//  Created by Xezun on 2020/7/18.
//  Copyright © 2020 Xezun. All rights reserved.
//

#import "XZML.h"
#import "XZML.Private.h"

static NSMutableAttributedString *XZMLNodeParser(XZMLContext *context, NSDictionary<NSAttributedStringKey, id> *parentAttributes, BOOL securityMode) {
    NSMutableArray<NSMutableAttributedString *> * const childAttributeStrings = [NSMutableArray arrayWithCapacity:32];
    NSMutableDictionary<NSAttributedStringKey, id> * const attributesM = [NSMutableDictionary dictionaryWithDictionary:parentAttributes];
    NSInteger star = 0;
    
    NSInteger index = 0;
    char character = 0;
    
    while (XZMLContextSearchASCIICharacter(context)) {
        index = context->srange.location + context->srange.length;
        character = context->xzmlcs[index];
        switch (character) {
            case '@': {
                // 上一个属性结束。
                context->attspr[context->attspc].length = index - context->attspr[context->attspc].location; // 属性长度。
                // 新的属性开始了。
                context->attspc += 1;
                context->attspr[context->attspc].location = index + 1;
                context->attspr[context->attspc].length = 0;
                
                // 字符长度+1
                context->srange.length += 1;
                break;
            }
            case '~': // 删除线
                context->attspr[context->attspc].length = index - context->attspr[context->attspc].location;
                XZMLAttributeUnderlineParser(context, attributesM);
                XZMLContextMoveAndPrepare(context);
                break;

            case '$': // 变星星
                context->attspr[context->attspc].length = index - context->attspr[context->attspc].location;
                star = XZMLAttributeStarParser(context);
                XZMLContextMoveAndPrepare(context);
                break;

            case '^': // 变色
                context->attspr[context->attspc].length = index - context->attspr[context->attspc].location;
                XZMLAttributeForegroundColorParser(context, attributesM);
                XZMLContextMoveAndPrepare(context);
                break;

            case '&': // 变字体
                context->attspr[context->attspc].length = index - context->attspr[context->attspc].location;
                XZMLAttributeFontParser(context, attributesM);
                XZMLContextMoveAndPrepare(context);
                break;

            case '>': // 当前节点结束了。
                goto COMPLETE_PARSING;

            case '<': { // 子节点开始了。
                NSString *string = XZMLStringParser(context);
                if (string != nil) {
                    NSMutableAttributedString *childAttrStrM = [[NSMutableAttributedString alloc] initWithString:string attributes:attributesM];
                    [childAttributeStrings addObject:childAttrStrM];
                }
                XZMLContextMoveAndPrepare(context);
                
                if (!securityMode || star == 0) {
                    NSMutableAttributedString *childAttrStrM = XZMLNodeParser(context, attributesM, securityMode);
                    [childAttributeStrings addObject:childAttrStrM];
                    XZMLContextMoveAndPrepare(context);
                } else { // 变星模式子节点不用解析
                    while (XZMLContextSearchASCIICharacter(context)) {
                        NSInteger const index = context->srange.location + context->srange.length;
                        if (context->xzmlcs[index] != '>') {
                            context->srange.length += 1;
                            continue;
                        }
                        XZMLContextMoveAndPrepare(context);
                        break;
                    }
                }
                break;
            }
            default:
                // 字符长度+1
                context->srange.length += 1;
                break;
        }
    }

    COMPLETE_PARSING:

    // 变星
    if (securityMode && star > 0) {
        NSString *string = [@"*" stringByPaddingToLength:star withString:@"*" startingAtIndex:0];
        attributesM[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleNone);
        return [[NSMutableAttributedString alloc] initWithString:string attributes:attributesM];
    }

    // 字符。
    NSString *string = XZMLStringParser(context);
    if (string != nil) {
        NSMutableAttributedString *childAttrStrM = [[NSMutableAttributedString alloc] initWithString:string attributes:attributesM];
        [childAttributeStrings addObject:childAttrStrM];
    }

    // 没有有效字串。
    if (childAttributeStrings.count == 0) {
        // 说明当前是一个空的 <>
        return [[NSMutableAttributedString alloc] initWithString:@"" attributes:attributesM];
    }

    // 合并所有子节点。
    NSMutableAttributedString *attributedStringM = childAttributeStrings[0];
    for (NSInteger i = 1; i < childAttributeStrings.count; i++) {
        [attributedStringM appendAttributedString:childAttributeStrings[i]];
    }
    return attributedStringM;
}

NSAttributedString *XZMLParser(NSString *xzmlString, NSDictionary<NSAttributedStringKey, id> *attributes, XZMLAlignments alignments, BOOL securityMode) {
    xzmlString = xzmlString.copy;
    
    NSMutableAttributedString *attributedStringM = [[NSMutableAttributedString alloc] init];
    
    NSInteger const length = [xzmlString lengthOfBytesUsingEncoding:(NSUTF8StringEncoding)];
    XZMLContext context = {xzmlString.UTF8String, length, {0, 0}, 0};
    
    while (XZMLContextSearchASCIICharacter(&context)) {
        char const character = context.xzmlcs[context.srange.location + context.srange.length];
        switch (character) {
            case '<': {
                XZMLParserMergeString(&context, attributedStringM, attributes);
                XZMLContextMoveAndPrepare(&context);
                
                NSAttributedString *childAttributedString = XZMLNodeParser(&context, attributes, securityMode);
                [attributedStringM appendAttributedString:childAttributedString];
                XZMLContextMoveAndPrepare(&context);
                break;
            }
            default: {
                context.srange.length += 1;
                break;
            }
        }
    }
    
    XZMLParserMergeString(&context, attributedStringM, attributes);
    
    if (alignments & XZMLAlignmentVerticalMiddle) {
        CGFloat __block max = 0;
        [attributedStringM enumerateAttributesInRange:NSMakeRange(0, attributedStringM.length) options:(0) usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            UIFont *font = attrs[NSFontAttributeName];
            max = MAX(max, font.xHeight);
        }];
        [attributedStringM enumerateAttributesInRange:NSMakeRange(0, attributedStringM.length) options:(0) usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            UIFont *font = attrs[NSFontAttributeName];
            CGFloat xHeight = font.xHeight;
            if (xHeight > 0 && xHeight < max) {
                CGFloat offset = (max - xHeight) * 0.5;
                [attributedStringM addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:range];
            }
        }];
    }
    
    return attributedStringM;
}
