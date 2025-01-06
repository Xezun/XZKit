//
//  Example0330ViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330ViewModel.h"
@import XZExtensions;
@import XZJSON;

@implementation Example0330ViewModel

- (void)prepare {
    [super prepare];

    XZMocoaModule *module = XZMocoa(@"https://mocoa.xezun.com/examples/30/table/");
    
    NSArray *data = @[@{
        @"group": @"100",
        @"model": @{ @"text": @"100. 测试 cell 模块未注册 Model、View、ViewModel" }
    }, @{
        @"group": @"101",
        @"model": @{ @"text": @"101. 测试 cell 模块未注册 View、ViewModel" }
    }, @{
        @"group": @"102",
        @"model": @{ @"text": @"102. 测试 cell 模块未注册 Model、ViewModel" }
    }, @{
        @"group": @"103",
        @"model": @{ @"text": @"103. 测试 cell 模块未注册 Model、View" }
    }, @{
        @"group": @"104",
        @"model": @{ @"text": @"104. 测试 cell 模块未注册 View" }
    }, @{
        @"group": @"105",
        @"model": @{ @"text": @"105. 测试 cell 模块未注册 Model" }
    }, @{
        @"group": @"106",
        @"model": @{ @"text": @"106. 测试 cell 模块未注册 ViewModel" }
    }, @{
        @"group": @"107",
        @"model": @{ @"text": @"107. 测试 cell 模块正常注册" }
    }, @{
        @"group": @"108",
        @"title": @"108. 测试 Header 模块未注册 Model、View、ViewModel",
        @"model": @{ @"text": @"108. 测试 Header、Footer 模块未注册 Model、View、ViewModel" },
        @"notes": @"108. 测试 Footer 模块未注册 Model、View、ViewModel"
    }, @{
        @"group": @"109",
        @"title": @"109. 测试 Header 模块未注册 Model、View",
        @"model": @{ @"text": @"109. 测试 Header、Footer 模块未注册 Model、View" },
        @"notes": @"109. 测试 Footer 模块未注册 Model、View"
    }, @{
        @"group": @"110",
        @"title": @"110. 测试 Header 模块未注册 Model",
        @"model": @{ @"text": @"110. 测试 Header、Footer 模块未注册 Model" },
        @"notes": @"110. 测试 Footer 模块未注册 Model"
    }];
    NSArray *groups = [data xz_map:^id(NSDictionary *dict, NSInteger idx, BOOL * _Nonnull stop) {
        XZMocoaModule *submodule = [module submoduleForName:dict[@"group"]];
        return [XZJSON decode:dict options:0 class:submodule.modelClass];
    }];
    
    _tableViewModel = [[XZMocoaTableViewModel alloc] initWithModel:groups];
    _tableViewModel.module = module;
    [self addSubViewModel:_tableViewModel];
}

@end
