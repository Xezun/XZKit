//
//  Example15Test02ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example15Test02ViewController.h"
@import XZLocale;
@import XZToast;

@interface Example15Test02ViewController ()

@property (nonatomic, copy) NSArray<NSString *> *strings;

@end

@implementation Example15Test02ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestData:^(NSDictionary<NSString *,NSString *> *data) {
        [self xz_hideToast:nil];
        NSString *string = XZLocalizedString(@"{0}在{1}去过{2}。", data[@"name"], data[@"date"], data[@"place"]);
        XZLanguage language = XZLocalization.isInAppLanguagePreferencesEnabled ? XZLocalization.preferredLanguage  : XZLocalization.effectiveLanguage;
        self.strings = @[
            XZLocalizedString(@"语言：{0}", language),
            XZLocalizedString(@"模版：{0}", @"{0}在{1}去过{2}"),
            XZLocalizedString(@"数据：{0}, {1}, {2}", data[@"name"], data[@"date"], data[@"place"]),
            XZLocalizedString(@"效果：{0}", string)
        ];
        [self.tableView reloadData];
    }];
    
//    [self xz_showToast:[XZToast loadingToast:@"加载中..."] duration:0 offset:CGPointMake(0, -50.0) completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    [self xz_layoutToastView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.strings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.strings[indexPath.row];
    return cell;
}

// Mark: ----

- (void)requestData:(void (^)(NSDictionary<NSString *, NSString *> *data))completion {
    [self connectServer:XZLocalization.preferredLanguage completion:^(NSDictionary *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(response[@"data"]);
        });
    }];
}

- (void)connectServer:(NSString *)language completion:(void (^)(NSDictionary *response))completion {
    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), queue, ^{
        NSDictionary *database = @{
            @"en": @{
                @"name": @"Xiao Ming",
                @"date": @"October 1, 2024",
                @"place": @"Tian'anmen Square"
            },
            @"zh-Hans": @{
                @"name": @"小明",
                @"date": @"2024年10月1日",
                @"place": @"天安门"
            }
        };
        id data = database[language];
        completion(@{
            @"code": @(0),
            @"message": @"ok",
            @"data": data
        });
    });
}

@end
