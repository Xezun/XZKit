//
//  XZMocoaGroupPlaceholderViewModel.m
//  XZKit
//
//  Created by Xezun on 2025/1/20.
//

#import "XZMocoaGroupPlaceholderViewModel.h"
#import "XZMocoaGroupCellViewModel.h"
#import "XZMocoaGroupViewModel.h"

#if DEBUG

@implementation XZMocoaGroupPlaceholderViewModel

- (instancetype)initWithModel:(XZMocoaGroupCellViewModel *)model {
    return [super initWithModel:model];
}

- (void)prepare {
    [super prepare];
    
    XZMocoaGroupCellViewModel * const cellViewModel  = self.model;
    
    XZMocoaName cellName = ((id<XZMocoaModel>)cellViewModel.model).mocoaName;
    if (cellName.length == 0) {
        cellName = @"<None>";
    }
    
    _reason = [self reasonByCheckingModule:cellViewModel.module];
    _detail = [NSString stringWithFormat:@"Name: cell=%@", cellName];
}

- (NSString *)reasonByCheckingModule:(XZMocoaModule *)module {
    if (!module) {
        return @"模块不存在";
    }
    if (!module.modelClass && !module.viewClass && !module.viewModelClass) {
        return @"模块缺少 Model、View、ViewModel";
    }
    if (!module.modelClass && !module.viewClass) {
        return @"模块缺少 Model、View";
    }
    if (!module.modelClass && !module.viewModelClass) {
        return @"模块缺少 Model、ViewModel";
    }
    if (!module.viewClass && !module.viewModelClass) {
        return @"模块缺少 View、ViewModel";
    }
    if (!module.modelClass) {
        return @"模块缺少 Model";
    }
    if (!module.viewClass) {
        return @"模块缺少 View";
    }
    if (!module.viewModelClass) {
        return @"模块缺少 ViewModel";
    }
    return @"模块不可用";
}

@end
#endif
