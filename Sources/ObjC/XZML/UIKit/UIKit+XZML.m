//
//  UIKit+XZML.m
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import "UIKit+XZML.h"
#import "Foundation+XZML.h"

@implementation UILabel (XZMLSupporting)

- (void)setXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    // 读取字体、字体颜色的默认值
    if (attributes == nil || attributes[NSFontAttributeName] == nil || attributes[NSForegroundColorAttributeName] == nil) {
        self.text = nil;
        NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithCapacity:attributes.count + 2];
        newAttributes[NSFontAttributeName]            = self.font;
        newAttributes[NSForegroundColorAttributeName] = self.textColor;
        if (attributes.count > 0) {
            [newAttributes addEntriesFromDictionary:attributes];
        }
        attributes = newAttributes;
    }
    self.attributedText = [[NSAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
}

- (void)setXZMLString:(NSString *)XZMLString {
    [self setXZMLString:XZMLString attributes:nil];
}

@end

@implementation UIButton (XZMLSupporting)

- (void)setXZMLString:(NSString *)XZMLString forState:(UIControlState)state attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    // 读取字体、字体颜色的默认值
    if (attributes == nil || attributes[NSFontAttributeName] == nil || attributes[NSForegroundColorAttributeName] == nil) {
        NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithCapacity:attributes.count + 2];
        newAttributes[NSFontAttributeName]            = self.titleLabel.font;
        newAttributes[NSForegroundColorAttributeName] = [self titleColorForState:state] ?: [self titleColorForState:(UIControlStateNormal)];
        if (attributes.count > 0) {
            [newAttributes addEntriesFromDictionary:attributes];
        }
        attributes = newAttributes;
    }
    NSAttributedString * const attributedTitle = [[NSAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
    [self setAttributedTitle:attributedTitle forState:state];
}

- (void)setXZMLString:(NSString *)XZMLString forState:(UIControlState)state {
    [self setXZMLString:XZMLString forState:state attributes:nil];
}

@end

@implementation UITextView (XZMLSupporting)

- (void)setXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    // 读取字体、字体颜色的默认值
    if (attributes == nil || attributes[NSFontAttributeName] == nil || attributes[NSForegroundColorAttributeName] == nil) {
        self.text = nil;
        NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithCapacity:attributes.count + 2];
        newAttributes[NSFontAttributeName]            = self.font;
        newAttributes[NSForegroundColorAttributeName] = self.textColor;
        if (attributes.count > 0) {
            [newAttributes addEntriesFromDictionary:attributes];
        }
        attributes = newAttributes;
    }
    self.attributedText = [[NSAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
}

- (void)setXZMLString:(NSString *)XZMLString {
    [self setXZMLString:XZMLString attributes:nil];
}

@end

@implementation UITextField (XZMLSupporting)

- (void)setXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    // 读取字体、字体颜色的默认值
    if (attributes == nil || attributes[NSFontAttributeName] == nil || attributes[NSForegroundColorAttributeName] == nil) {
        self.text = nil;
        NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithCapacity:attributes.count + 2];
        newAttributes[NSFontAttributeName]            = self.font;
        newAttributes[NSForegroundColorAttributeName] = self.textColor;
        if (attributes.count > 0) {
            [newAttributes addEntriesFromDictionary:attributes];
        }
        attributes = newAttributes;
    }
    self.attributedText = [[NSAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
}

- (void)setXZMLString:(NSString *)XZMLString {
    [self setXZMLString:XZMLString attributes:nil];
}

@end
