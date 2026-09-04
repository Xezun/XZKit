//
//  Example0320HeaderFooterView.m
//  Example
//
//  Created by 徐臻 on 2026/9/4.
//

#import "Example0320HeaderFooterView.h"

@implementation Example0320HeaderFooterView

+ (void)load {
    XZMocoaModule *module = XZMocoa(@"https://mocoa.xezun.com/examples/20/table/");
    module.header.viewClass = self;
    module.footer.viewClass = self;
}

@end
