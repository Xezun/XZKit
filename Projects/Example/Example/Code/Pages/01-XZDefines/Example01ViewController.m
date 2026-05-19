//
//  Example01ViewController.m
//  Example
//
//  Created by 徐臻 on 2025/2/26.
//

#import "Example01ViewController.h"
@import XZKit;
@import MapKit;

@interface Example01ViewController ()

@end

@implementation Example01ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self xz_showToast:[XZToast messageToast:@"请查看控制台输出情况"]];
    
    switch (indexPath.row) {
        case 0:
            [self exampleDefer];
            break;
        case 1:
            [self exampleEmpty];
            break;
        case 3: {
            [self exampleMacros];
            break;
        }
        case 4: {
            [self exampleKVC];
            break;
        }
        default:
            break;
    }
}

- (void)exampleDefer {
    NSLog(@"==============================");
    NSLog(@"演示 defer 的作用与用法：将作用域内，写在前面语句，放到最后执行。");
    NSLog(@"将代码按书写顺序添加序号，观察代码最终的执行顺序。");
    defer(^{
        NSLog(@"1、文件处理之后的操作");
    });
    
    NSLog(@"2、打开文件");
    defer(^{
        NSLog(@"3、关闭文件");
    });
    
    NSLog(@"4、读取文件");
    NSLog(@"5、更新文件");
}

- (void)exampleEmpty {
    NSLog(@"==============================");
    NSLog(@"演示 isNonEmpty 与 asNonEmpty 的作用与用法。");
    {
        NSArray *objects = @[
            @"",
            @"foo",
            NSNull.null,
            @[],
            @[@"bar"],
            @{},
            @{@"foo": @"bar"}
        ];
        
        NSLog(@"判断 NSString 非空");
        for (NSString *object in objects) {
            NSString *value = [NSString xz_stringWithJSONObject:object];
            NSString *class = NSStringFromClass(object.class);
            NSString *result = isNonEmpty(object) ? @"true" : @"false";
            NSLog(@"实际值: %@, 实际值类型: %@, 结果: %@", value, class, result);
        }
        
        NSLog(@"判断 NSArray 非空");
        for (NSArray *object in objects) {
            NSString *value = [NSString xz_stringWithJSONObject:object];
            NSString *class = NSStringFromClass(object.class);
            NSString *result = isNonEmpty(object) ? @"true" : @"false";
            NSLog(@"实际值: %@, 实际值类型: %@, 结果: %@", value, class, result);
        }
        
        NSLog(@"判断 NSDictionary 非空");
        for (NSDictionary *object in objects) {
            NSString *value = [NSString xz_stringWithJSONObject:object];
            NSString *class = NSStringFromClass(object.class);
            NSString *result = isNonEmpty(object) ? @"true" : @"false";
            NSLog(@"实际值: %@, 实际值类型: %@, 结果: %@", value, class, result);
        }
    }
    
    {
        NSDictionary<NSString *, id> *objects = @{
            @"nil": NSNull.null,
            @"EmptyString": @"",
            @"NonEmptyString": @"non empty string",
            @"EmptyArray": @[],
            @"NonEmptyArray": @[@"non", @"empty", @"array"],
            @"EmptyDictionary": @{},
            @"NonEmptyDictionary": @{ @"key": @"non empty dictionary" }
        };
        
        NSLog(@"获取 NSString 对象：若值为非空字符串，则使用该值，否则使用默认值");
        [objects enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull object, BOOL * _Nonnull stop) {
            object = (object == (id)kCFNull ? nil : object);
            NSString *value = [NSString xz_stringWithJSONObject:object];
            NSString *class = NSStringFromClass(object_getClass(object));
            NSString *result = asNonEmpty(object, @"默认值");
            NSLog(@"实际值: %@, 实际值类型: %@, 结果: %@", value, class, result);
        }];
        
        NSLog(@"获取 NSArray 对象：若值为非空数组，那么使用该数组，否则使用默认值");
        [objects enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull object, BOOL * _Nonnull stop) {
            object = (object == (id)kCFNull ? nil : object);
            NSString *value = [NSString xz_stringWithJSONObject:object];
            NSString *class = NSStringFromClass(object_getClass(object));
            NSString *result = [NSString xz_stringWithJSONObject:asNonEmpty(object, @[@"默认数组"])];
            NSLog(@"实际值: %@, 实际值类型: %@, 结果: %@", value, class, result);
        }];
        
        NSLog(@"获取 NSDictionary 对象：若值为非空字典，那么使用该值，否则使用默认值");
        [objects enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull object, BOOL * _Nonnull stop) {
            object = (object == (id)kCFNull ? nil : object);
            NSString *value = [NSString xz_stringWithJSONObject:object];
            NSString *class = NSStringFromClass(object_getClass(object));
            NSString *result = [NSString xz_stringWithJSONObject:asNonEmpty(object, @{@"字典": @"默认值"})];
            NSLog(@"实际值: %@, 实际值类型: %@, 结果: %@", value, class, result);
        }];
    }
}

- (void)exampleMacros {
    NSLog(@"==============================");
    NSLog(@"演示 @enweak @deweak 宏的作用与用法。");
    
    NSString *(^block)(void)  = nil;
    
    {
        NSLog(@"===作用域开始===");
        NSObject *object = [NSObject new];
        NSLog(@"弱引用编码的对象是：%@", object);
        
        @enweak(object);
        block = ^NSString *{
            @deweak(object);
            return [NSString stringWithFormat:@"%@", object];
        };
        
        NSLog(@"在作用域内，弱引用解码的对象是：%@", block());
        NSLog(@"===作用域结束===");
    }
    
    NSLog(@"在生命周期外，弱引用解码的对象是：%@", block());
}


- (void)exampleKVC {
    NSLog(@"==============================");
    NSLog(@"测试 Key Value Coding 的相关规则");
    
    NSDictionary *obj = @{
        @"items": @[
            @{ @"user": @{ @"id": @"2" } },
            @{ @"user": @{ @"id": @"3" } },
            @{ @"user": @{ @"id": @"4" } }
        ],
        @"nums": @[
            @(5), @(1), @(2), @(3), @(4)
        ]
    };
    
    NSString *key = @"items.user";
    NSLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"items.user.id";
    NSLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"nums.@avg.self";
    NSLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"nums.@min.self";
    NSLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"nums.@sum.self";
    NSLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"@count";
    NSLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    NSLog(@"%@", [[[obj valueForKeyPath:@"items"] objectAtIndex:0] valueForKeyPath:@"user.id"]);
}

- (void)xcodeMacros {
    NSLog(@"__IPHONE_OS_VERSION_MIN_REQUIRED => %d", __IPHONE_OS_VERSION_MIN_REQUIRED);
}

- (IBAction)testAnimation {
//    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:100.0];
//    UIImage *image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
//    image = [image imageByApplyingSymbolConfiguration:config];
    UIImage *image = [UIImage imageNamed:@"ex-12-error"];
//    image = [image imageWithTintColor:UIColor.redColor renderingMode:(UIImageRenderingModeAlwaysOriginal)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    imageView.image = image;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = UIColor.darkGrayColor;
    [self.view addSubview:imageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:3.0 animations:^{
            imageView.frame = CGRectMake(150, 150, 1, 1);
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
        }];
    });
}

@end
