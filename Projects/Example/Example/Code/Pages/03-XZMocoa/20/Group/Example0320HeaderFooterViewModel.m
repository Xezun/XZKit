//
//  Example0320HeaderFooterViewModel.m
//  Example
//
//  Created by 徐臻 on 2026/9/4.
//

#import "Example0320HeaderFooterViewModel.h"

@implementation Example0320HeaderFooterViewModel

+ (void)load {
    XZMocoaModule *module = XZMocoa(@"https://mocoa.xezun.com/examples/20/table/");
    module.header.viewModelClass = self;
    module.footer.viewModelClass = self;
}

@end
