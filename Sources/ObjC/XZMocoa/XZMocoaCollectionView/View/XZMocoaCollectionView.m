//
//  XZMocoaCollectionView.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/24.
//

@import ObjectiveC;
#import "XZMocoaCollectionView.h"
#import "XZMocoaCollectionCell.h"
#import "XZMocoaCollectionSupplementView.h"
#import "XZMocoaCollectionPlaceholderCell.h"
#import "XZMocoaCollectionPlaceholderSupplementView.h"
#import "XZMocoaCollectionViewProxy.h"

@implementation XZMocoaCollectionView

@dynamic contentView;
@dynamic viewModel;

+ (void)initialize {
    if (self == [XZMocoaCollectionView class]) {
        unsigned int count = 0;
        Method *list = class_copyMethodList([XZMocoaCollectionViewProxy class], &count);
        for (unsigned int i = 0; i < count; i++) {
            Method const method = list[i];
            SEL const selector = method_getName(method);
            IMP const implemnt = method_getImplementation(method);
            const char * const types = method_getTypeEncoding(method);
            if (!class_addMethod(self, selector, implemnt, types)) {
                NSLog(@"为 %@ 添加方法 %@ 失败", self, NSStringFromSelector(selector));
            }
        }
        free(list);
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [super initWithCoder:coder];
}

- (instancetype)initWithCollectionViewClass:(Class)collectionViewClass layout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        UICollectionView *contentView = [[collectionViewClass alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [super setContentView:contentView];
    }
    return self;
}

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout {
    return [self initWithFrame:UIScreen.mainScreen.bounds layout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout {
    self = [self initWithCollectionViewClass:UICollectionView.class layout:layout];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    return [self initWithCollectionViewClass:UICollectionView.class layout:layout];
}

- (void)contentViewWillChange:(UIScrollView *)newValue {
    [super contentViewWillChange:newValue];
    
    UICollectionView * const collectionView = self.contentView;
    collectionView.delegate = nil;
    collectionView.dataSource = nil;
}

- (void)contentViewDidChange:(UIScrollView *)oldValue {
    [super contentViewDidChange:oldValue];
    
    UICollectionView * const collectionView = self.contentView;
    collectionView.delegate   = self;
    collectionView.dataSource = self;
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    self.viewModel.delegate = self;
    
    // 刷新视图。
    UICollectionView * const collectionView = self.contentView;
    [collectionView reloadData];
}

- (void)reloadData {
    [self.viewModel reloadData];
}

- (void)performBatchUpdates:(void (NS_NOESCAPE ^)(void))updates completion:(void (^)(BOOL))completion {
    [self.viewModel performBatchUpdates:updates completion:completion];
}

@end

