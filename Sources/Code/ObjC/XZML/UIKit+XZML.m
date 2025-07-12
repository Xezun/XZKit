//
//  UIKit+XZML.m
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import "UIKit+XZML.h"
#import "Foundation+XZML.h"

@implementation UILabel (XZML)

- (void)setXZMLText:(NSString *)XZMLString attributes:(nullable NSDictionary<NSString *,id> *)attributes {
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
    self.attributedText = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
}

- (void)setXZMLText:(NSString *)XZMLString {
    [self setXZMLText:XZMLString attributes:nil];
}

@end

@implementation UIButton (XZML)

- (void)setXZMLTitle:(NSString *)XZMLString forState:(UIControlState)state attributes:(nullable NSDictionary<NSString *,id> *)attributes {
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
    id const title = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
    [self setAttributedTitle:title forState:state];
}

- (void)setXZMLTitle:(NSString *)XZMLString forState:(UIControlState)state {
    [self setXZMLTitle:XZMLString forState:state attributes:nil];
}

@end

@implementation UITextView (XZML)

- (void)setXZMLText:(NSString *)XZMLString attributes:(NSDictionary<NSString *,id> *)attributes {
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
    self.attributedText = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
}

- (void)setXZMLText:(NSString *)XZMLString {
    [self setXZMLText:XZMLString attributes:nil];
}

@end

@implementation UITextField (XZML)

- (void)setXZMLText:(NSString *)XZMLString attributes:(NSDictionary<NSString *,id> *)attributes {
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
    self.attributedText = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
}

- (void)setXZMLText:(NSString *)XZMLString {
    [self setXZMLText:XZMLString attributes:nil];
}

@end
