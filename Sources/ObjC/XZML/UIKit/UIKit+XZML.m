//
//  UIKit+XZML.m
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import "UIKit+XZML.h"
#import "Foundation+XZML.h"

@implementation UILabel (XZML)

- (void)setXZML:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
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
    self.attributedText = [[NSMutableAttributedString alloc] initWithXZML:XZMLString attributes:attributes];
}

- (void)setXZML:(NSString *)XZMLString {
    [self setXZML:XZMLString attributes:nil];
}

@end

@implementation UIButton (XZML)

- (void)setXZML:(NSString *)XZMLString forState:(UIControlState)state attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
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
    id const title = [[NSMutableAttributedString alloc] initWithXZML:XZMLString attributes:attributes];
    [self setAttributedTitle:title forState:state];
}

- (void)setXZML:(NSString *)XZMLString forState:(UIControlState)state {
    [self setXZML:XZMLString forState:state attributes:nil];
}

@end

@implementation UITextView (XZML)

- (void)setXZML:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
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
    self.attributedText = [[NSMutableAttributedString alloc] initWithXZML:XZMLString attributes:attributes];
}

- (void)setXZML:(NSString *)XZMLString {
    [self setXZML:XZMLString attributes:nil];
}

@end

@implementation UITextField (XZML)

- (void)setXZML:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
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
    self.attributedText = [[NSMutableAttributedString alloc] initWithXZML:XZMLString attributes:attributes];
}

- (void)setXZML:(NSString *)XZMLString {
    [self setXZML:XZMLString attributes:nil];
}

@end
