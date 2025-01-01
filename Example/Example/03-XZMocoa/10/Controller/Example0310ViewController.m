//
//  Example0310ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import "Example0310ViewController.h"
// View
#import "Example0310RootView.h"
// Model
#import "Example0310ContactViewModel.h"
#import "Example0310Model.h"
@import XZExtensions;
@import XZJSON;

@interface Example0310ViewController ()
@property (nonatomic, readonly) Example0310RootView *rootView;
@end

@implementation Example0310ViewController

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/10/").viewClass = self;
}

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(nullable NSString *)nibName bundle:(nullable NSBundle *)bundle {
    self = [super initWithMocoaOptions:options nibName:nibName bundle:bundle];
    if (self) {
        self.title = @"Example 10";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (Example0310RootView *)rootView {
    return (id)self.view;
}

- (void)loadView {
    self.view = [[Example0310RootView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 480.0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = rgb(0xEEEEEE);
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0);
    
    [self loadData];
}

- (void)setData:(Example0310Model *)data {
    { // 渲染 mvc 视图
        self.rootView.contentView.title = data.content.title;
        self.rootView.contentView.content = data.content.content;
    }
    
    { // 渲染 mvvm 模块视图
        // mvvm 模块可以注册为 Mocoa 模块，可以通过 url 来获取
        // 因此使用 mvvm 设计模式，可以通过下发 url 很方便的展示任意 mvvm 模块视图。
        // 当然，这里只是展示固定的视图，相当于特例。
        Example0310ContactViewModel *viewModel = [[Example0310ContactViewModel alloc] initWithModel:data.contact ready:YES];
        self.rootView.contactView.viewModel = viewModel;
    }
    
    // layout the ui to fit the data
    [self.rootView setNeedsLayout];
}

- (void)loadData {
    // 从网络或数据库获取数据，这里省略过程。
    NSDictionary *dict = @{
        @"content": @{
            @"title": @"示例说明",
            @"content": @"本示例演示了MVVM模块的开发，以及如何在MVC结构中使用MVVM模块。\n"
            "1、控制器为MVC结构的。\n"
            "2、ContentView为传统的View视图，数据在控制器中渲染（这里的渲染指的是设置text/image等操作，并非CALayer渲染）。\n"
            "3、ContactView为MVVM模块，在MVC中使用它时，我们不需要数据关心细节，直接使用数据构造ViewModel，然后由View根据ViewModel进行渲染即可。\n"
            "4、关于mvvm模块的渲染流程，还有另外一种方式，即在创建view时，同时创建model和viewModel对象，利用绑定监听数据变化，然后更新视图。"
            "但是在大部分业务场景中，数据在渲染后并不会更新。即使在tableView/collectionView中，cell在呈现的过程中，数据也大概不会变动。"
            "对于cell视图的重用，只是减少了创建视图的成本，并不是单纯的数据变化，即重用的cell应与新创建的cell一视同仁。"
        },
        @"contact": @{
            @"card": @"contact",
            @"firstName": @"Foo",
            @"lastName": @"Bar",
            @"photo": @"https://developer.apple.com/assets/elements/icons/xcode/xcode-64x64_2x.png",
            @"phone": @"13923459876",
            @"address": @"北京市海淀区人民路幸福里小区7号楼6单元503室"
        }
    };
    
    // 解析数据
    Example0310Model *data = [XZJSON decode:dict options:0 class:[Example0310Model class]];
    
    // 更新视图
    [self setData:data];
}

@end
