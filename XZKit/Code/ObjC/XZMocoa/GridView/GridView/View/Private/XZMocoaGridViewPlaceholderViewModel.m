//
//  XZMocoaGridViewPlaceholderViewModel.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import "XZMocoaGridViewPlaceholderViewModel.h"
#import "XZMocoaGridViewSectionViewModel.h"

#if DEBUG
@implementation XZMocoaGridViewPlaceholderViewModel

- (instancetype)initWithModel:(XZMocoaGridViewCellViewModel *)model {
    return [super initWithModel:model];
}

- (void)prepare {
    [super prepare];
    
    XZMocoaViewModel * const viewModel = self.model;
    XZMocoaGridViewSectionViewModel * const superViewModel = viewModel.superViewModel;
    
    _reason = [self reasonByCheckingModule:viewModel.module];
    
    XZMocoaName name1 = ((id<XZMocoaModel>)superViewModel.model).mocoaName;
    XZMocoaName name2 = ((id<XZMocoaModel>)viewModel.model).mocoaName;
    if (name1.length == 0) name1 = @"<None>";
    if (name2.length == 0) name2 = @"<None>";
    
    if ([superViewModel indexOfCellViewModel:(id)viewModel] != NSNotFound) {
        _detail = [NSString stringWithFormat:@"Name: section=%@, cell=%@ \nData: %@", name1, name2, viewModel.model];
    } else {
        [superViewModel.supplementaryViewModels enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind kind, NSArray<XZMocoaViewModel *> *obj, BOOL * _Nonnull stop) {
            if ([obj containsObject:viewModel]) {
                _detail = [NSString stringWithFormat:@"Name: section=%@, %@=%@ \nData: %@", name1, kind, name2, viewModel.model];
                *stop = YES;
            }
        }];
    }
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
