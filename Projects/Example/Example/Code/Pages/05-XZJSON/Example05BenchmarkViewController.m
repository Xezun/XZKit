//
//  Example05BenchmarkViewController.m
//  Example
//
//  Created by 徐臻 on 2025/2/27.
//

#import "Example05BenchmarkViewController.h"
#import "Example05Model.h"
#import "XZLog.h"
@import XZKit;
@import YYModel;

@interface Example05BenchmarkViewController ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIButton *markButton;
@property (nonatomic, weak) IBOutlet UIButton *timeButton;
@end

@implementation Example05BenchmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)markButtonAction:(UIButton *)sender {
    self.markButton.enabled = NO;
    self.timeButton.enabled = NO;
    _textLabel.text = [NSString stringWithFormat:@"Device: %@\n\n", UIDevice.currentDevice.xz_productName];
    
    [self xz_showToast:[XZToast loadingToast:@"请稍后"] duration:0 completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self benchmarkGithubUser];
        [self benchmarkWeiboStatus];
        
        [self testRobustness];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.markButton.enabled = YES;
            self.timeButton.enabled = YES;
            
            XZLog(@"%@", self.textLabel.text);
        });
    });
}

- (IBAction)timeButtonAction:(UIButton *)sender {
    self.markButton.enabled = NO;
    self.timeButton.enabled = NO;
    _textLabel.text = @"请打开 Instruments Time Profiler 分析耗时操作！\n\n为避免干扰，本操作没有 Toast 提示。";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05GHUser" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    int count = 10000;
    void (^yyTest)(void) = ^{
        NSMutableArray *holder = [NSMutableArray arrayWithCapacity:count * 2];
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05YYGHUser *user = [Example05YYGHUser yy_modelWithJSON:json];
                [holder addObject:user];
                
                // YYModel
                NSDictionary *json = [user yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
    };
    
    void (^xzTest)(void) = ^{
        NSMutableArray *holder = [NSMutableArray arrayWithCapacity:count * 2];
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05XZGHUser *user = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
                [holder addObject:user];
                
                NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:64];
                [XZJSON model:user encodeIntoDictionary:json];
                [holder addObject:json];
            }
        }
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        yyTest();
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            xzTest();
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.markButton.enabled = YES;
                self.timeButton.enabled = YES;
            });
        });
    });
}

- (void)addText:(NSString *)text {
    _textLabel.text = [_textLabel.text stringByAppendingString:text];
}

- (void)benchmarkHeader:(NSString *)name count:(NSInteger)count {
    [self addText:@"------------------------------------\n"];
    [self addText:[NSString stringWithFormat:@"Benchmark: %@ (%ld times)  \n", name, count]];
    [self addText:@"------------------------------------\n"];
    [self addText:@"Library | decode | encode | archive \n"];
    [self addText:@"--------|--------|--------|---------\n"];
}

- (void)benchmarkResult:(NSString *)text decode:(NSTimeInterval)duration1 encode:(NSTimeInterval)duration2 archive:(NSTimeInterval)duration3 {
    NSString *string1 = [NSString stringWithFormat:@"%-7s", text.UTF8String];
    NSString *string2 = duration1 <= 0 ? @"        " : [NSString stringWithFormat:@"%6.2f", duration1];
    NSString *string3 = duration2 <= 0 ? @"        " : [NSString stringWithFormat:@"%6.2f", duration2];
    NSString *string4 = duration3 <= 0 ? @"        " : [NSString stringWithFormat:@"%6.2f", duration3];
    NSString *string = [NSString stringWithFormat:@"%@ | %@ | %@ | %@  \n", string1, string2, string3, string4];
    [self addText:string];
}

- (void)benchMarkFooter {
    [self addText:@"------------------------------------\n"];
    [self addText:@"\n"];
}

- (void)benchmarkGithubUser {
    /// get json data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05GHUser" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self addText:@"------------------------------------\n"];
    {
        if ([self checkGHUser:(id)[Example05YYGHUser yy_modelWithJSON:json]]) {
            [self addText:@"YYModel decode verify: pass\n"];
        } else {
            [self addText:@"YYModel decode verify: fail\n"];
        }
        if ([self checkGHUser:[XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]]]) {
            [self addText:@"XZJSON  decode verify: pass\n"];
        } else {
            [self addText:@"XZJSON  decode verify: fail\n"];
        };
    }
    [self addText:@"------------------------------------\n"];
    
    int const count = 10000;
    [self benchmarkHeader:@"GHUser" count:count];
    
    /// Benchmark
    NSTimeInterval begin, end;
    
    /// warm up (NSDictionary's hot cache, and JSON to model framework cache)
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            // YYModel
            [Example05YYGHUser yy_modelWithJSON:json];
            
            // XZJSON
            [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        }
    }
    /// warm up holder
    NSMutableArray *holder = [NSMutableArray new];
    for (int i = 0; i < 1800; i++) {
        [holder addObject:[NSDate new]];
    }
    [holder removeAllObjects];
    
    [self xz_hideToast:nil];
    
    NSTimeInterval duration1 = 0;
    NSTimeInterval duration2 = 0;
    NSTimeInterval duration3 = 0;
    
    /*------------------- JSON Serialization -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        duration1 = (end - begin) * 1000;
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        duration2 = (end - begin) * 1000;
        
        [self benchmarkResult:@"JSON" decode:duration1 encode:duration2 archive:0];
    }
    
    /*------------------- YYModel -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05YYGHUser *user = [Example05YYGHUser yy_modelWithJSON:json];
                [holder addObject:user];
            }
        }
        end = CACurrentMediaTime();
        duration1 = (end - begin) * 1000;
        
        Example05YYGHUser *user = [Example05YYGHUser yy_modelWithJSON:json];
        if (user.userID == 0) NSLog(@"error!");
        if (!user.login) NSLog(@"error!");
        if (!user.htmlURL) NSLog(@"error");
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [user yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        duration2 = (end - begin) * 1000;
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:NO error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        duration3 = (end - begin) * 1000;
        
        [self benchmarkResult:@"YYModel" decode:duration1 encode:duration2 archive:duration3];
    }
    
    /*------------------- XZJSON -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05XZGHUser *user = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
                [holder addObject:user];
            }
        }
        end = CACurrentMediaTime();
        duration1 = (end - begin) * 1000;
        
        Example05XZGHUser *user = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        if (user.userID == 0) NSLog(@"error!");
        if (!user.login) NSLog(@"error!");
        if (!user.htmlURL) NSLog(@"error");
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:64];
                [XZJSON model:user encodeIntoDictionary:json];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        [XZJSON model:user encodeIntoDictionary:json];
        if ([NSJSONSerialization isValidJSONObject:json]) {
            duration2 = (end - begin) * 1000;
        } else {
            duration2 = 0;
        }
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:NO error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        duration3 = (end - begin) * 1000;
        
        [self benchmarkResult:@"XZJSON" decode:duration1 encode:duration2 archive:duration3];
    }
    
    [self benchMarkFooter];
}

- (void)benchmarkWeiboStatus {
    int const count = 1000;
    [self benchmarkHeader:@"WeiboModel" count:count];
    
    /// get json data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05Weibo" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    /// Benchmark
    NSTimeInterval begin, end;
    
    /// warm up (NSDictionary's hot cache, and JSON to model framework cache)
    @autoreleasepool {
        for (int i = 0; i < count * 2; i++) {
            // YYModel
            [Example05YYWeiboStatus yy_modelWithJSON:json];
        
            // XZJSON
            [XZJSON decode:json options:kNilOptions class:[Example05XZWeiboStatus class]];
        }
    }
    
    /// warm up holder
    NSMutableArray *holder = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        [holder addObject:[NSData new]];
    }
    [holder removeAllObjects];
    
    NSTimeInterval duration1 = 0;
    NSTimeInterval duration2 = 0;
    NSTimeInterval duration3 = 0;
    
    /*------------------- YYModel -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05YYWeiboStatus *feed = [Example05YYWeiboStatus yy_modelWithJSON:json];
                [holder addObject:feed];
            }
        }
        end = CACurrentMediaTime();
        duration1 = (end - begin) * 1000;
        
        Example05YYWeiboStatus *feed = [Example05YYWeiboStatus yy_modelWithJSON:json];
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [feed yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        if ([NSJSONSerialization isValidJSONObject:[feed yy_modelToJSONObject]]) {
            duration2 = (end - begin) * 1000;
        } else {
            duration2 = 0;
        }
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:feed requiringSecureCoding:NO error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        duration3 = (end - begin) * 1000;
        
        [self benchmarkResult:@"YYModel" decode:duration1 encode:duration2 archive:duration3];
    }

    /*------------------- XZJSON -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05XZWeiboStatus *feed = [XZJSON decode:json options:kNilOptions class:[Example05XZWeiboStatus class]];
                [holder addObject:feed];
            }
        }
        end = CACurrentMediaTime();
        duration1 = (end - begin) * 1000;
        
        Example05XZWeiboStatus *feed = [XZJSON decode:json options:kNilOptions class:[Example05XZWeiboStatus class]];
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *json = [NSMutableDictionary dictionary];
                [XZJSON model:feed encodeIntoDictionary:json];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        [XZJSON model:feed encodeIntoDictionary:json];
        if ([NSJSONSerialization isValidJSONObject:json]) {
            duration2 = (end - begin) * 1000;
        } else {
            duration2 = 0;
        }
        
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:feed requiringSecureCoding:NO error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        duration3 = (end - begin) * 1000;
        
        [self benchmarkResult:@"XZJSON" decode:duration1 encode:duration2 archive:duration3];
    }
    
    [self benchMarkFooter];
}

- (void)testRobustness {
    
    {
        [self addText:@"----------------------\n"];
        [self addText:@"The property is NSString, but the json value is number:\n"];
        NSString *jsonStr = @"{\"type\":1}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            [self addText:[NSString stringWithFormat:@"%s ",model.UTF8String]];
            if (!user) {
                [self addText:@"⚠️ model is nil\n"];
            } else {
                NSString *type = ((Example05YYGHUser *)user).type;
                if (type == nil || type == (id)[NSNull null]) {
                    [self addText:@"⚠️ property is nil\n"];
                } else if ([type isKindOfClass:[NSString class]]) {
                    [self addText:[NSString stringWithFormat:@"✅ property is %s\n",NSStringFromClass(type.class).UTF8String]];
                } else {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %s\n",NSStringFromClass(type.class).UTF8String]];
                }
            }
        };
        
        // YYModel
        Example05YYGHUser *yyUser = [Example05YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZGHUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        logError(@"XZJSON:         ", xzUser);
        
        [self addText:@"\n"];
    }
    
    {
        [self addText:@"----------------------\n"];
        [self addText:@"The property is int, but the json value is string:\n"];
        NSString *jsonStr = @"{\"followers\":\"100\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            [self addText:[NSString stringWithFormat:@"%s ",model.UTF8String]];
            if (!user) {
                [self addText:@"⚠️ model is nil\n"];
            } else {
                UInt32 num = ((Example05YYGHUser *)user).followers;
                if (num != 100) {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %u\n",(unsigned int)num]];
                } else {
                    [self addText:[NSString stringWithFormat:@"✅ property is %u\n",(unsigned int)num]];
                }
            }
        };
        
        // YYModel
        Example05YYGHUser *yyUser = [Example05YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZGHUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        logError(@"XZJSON:         ", xzUser);
    }
    
    
    {
        [self addText:@"----------------------\n"];
        [self addText:@"The property is NSDate, and the json value is string:\n"];
        NSString *jsonStr = @"{\"updated_at\":\"2009-04-02 03:35:22\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            [self addText:[NSString stringWithFormat:@"%s ",model.UTF8String]];
            if (!user) {
                [self addText:@"⚠️ model is nil\n"];
            } else {
                NSDate *date = ((Example05YYGHUser *)user).updatedAt;
                if (date == nil || date == (id)[NSNull null]) {
                    [self addText:@"⚠️ property is nil\n"];
                } else if ([date isKindOfClass:[NSDate class]]) {
                    [self addText:[NSString stringWithFormat:@"✅ property is %s\n",NSStringFromClass(date.class).UTF8String]];
                } else {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %s\n",NSStringFromClass(date.class).UTF8String]];
                }
            }
        };
        
        // YYModel
        Example05YYGHUser *yyUser = [Example05YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZGHUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        logError(@"XZJSON:         ", xzUser);
        [self addText:@"\n"];
    }
    
    
    {
        [self addText:@"----------------------\n"];
        [self addText:@"The property is NSValue, and the json value is string:\n"];
        NSString *jsonStr = @"{\"test\":\"https://github.com\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            [self addText:[NSString stringWithFormat:@"%s ",model.UTF8String]];
            if (!user) {
                [self addText:@"⚠️ model is nil\n"];
            } else {
                NSValue *valur = ((Example05YYGHUser *)user).test;
                if (valur == nil || valur == (id)[NSNull null]) {
                    [self addText:@"✅ property is nil\n"];
                } else if ([valur isKindOfClass:[NSURLRequest class]]) {
                    [self addText:[NSString stringWithFormat:@"✅ property is %s\n",NSStringFromClass(valur.class).UTF8String]];
                } else {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %s\n",NSStringFromClass(valur.class).UTF8String]];
                }
            }
        };
        // YYModel
        Example05YYGHUser *yyUser = [Example05YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZGHUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        logError(@"XZJSON:         ", xzUser);
        [self addText:@"\n"];
    }
    
}


static BOOL CheckStringValue(NSString *modelValue, NSString *dictValue) {
    if (dictValue == (id)kCFNull) {
        return modelValue == nil;
    }
    return [dictValue isEqualToString:modelValue];
}

static BOOL CheckBoolValue(BOOL modelValue, NSNumber *dictValue) {
    return modelValue == dictValue.boolValue;
}

static BOOL CheckNumberValue(NSInteger modelValue, NSNumber *dictValue) {
    return modelValue == dictValue.integerValue;
}

static BOOL CheckDateValue(NSDate *modelValue, id dictValue) {
    if ([dictValue isKindOfClass:NSString.class]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = NSLocale.currentLocale;
        formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        
        NSString *dateString = [formatter stringFromDate:modelValue];
        return [(NSString *)dictValue isEqualToString:dateString];
    }
    if ([dictValue isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)dictValue integerValue] == (NSInteger)[modelValue timeIntervalSince1970];
    }
    return NO;
}

- (BOOL)checkGHUser:(Example05XZGHUser *)model {
    NSInteger count = 0;
    
    NSString *path = [NSBundle.mainBundle pathForResource:@"Example05GHUser" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
#define compareString(modelValue, dictValue) (dictValue == )
    
    if (CheckStringValue(model.login, dict[@"login"])) {
        count += 1;
    }
    if (CheckNumberValue(model.userID, dict[@"id"])) {
        count += 1;
    }
    if (CheckStringValue(model.avatarURL, dict[@"avatar_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.gravatarID, dict[@"gravatar_id"])) {
        count += 1;
    }
    if (CheckStringValue(model.url, dict[@"url"])) {
        count += 1;
    }
    if (CheckStringValue(model.htmlURL, dict[@"html_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.followersURL, dict[@"followers_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.followingURL, dict[@"following_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.gistsURL, dict[@"gists_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.starredURL, dict[@"starred_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.subscriptionsURL, dict[@"subscriptions_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.organizationsURL, dict[@"organizations_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.reposURL, dict[@"repos_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.eventsURL, dict[@"events_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.receivedEventsURL, dict[@"received_events_url"])) {
        count += 1;
    }
    if (CheckStringValue(model.type, dict[@"type"])) {
        count += 1;
    }
    if (CheckBoolValue(model.siteAdmin, dict[@"site_admin"])) {
        count += 1;
    }
    if (CheckStringValue(model.name, dict[@"name"])) {
        count += 1;
    }
    if (CheckStringValue(model.company, dict[@"company"])) {
        count += 1;
    }
    if (CheckStringValue(model.blog, dict[@"blog"])) {
        count += 1;
    }
    if (CheckStringValue(model.location, dict[@"location"])) {
        count += 1;
    }
    if (CheckStringValue(model.email, dict[@"email"])) {
        count += 1;
    }
    if (CheckStringValue(model.hireable, dict[@"hireable"])) {
        count += 1;
    }
    if (CheckStringValue(model.bio, dict[@"bio"])) {
        count += 1;
    }
    if (CheckNumberValue(model.publicRepos, dict[@"public_repos"])) {
        count += 1;
    }
    if (CheckNumberValue(model.publicGists, dict[@"public_gists"])) {
        count += 1;
    }
    if (CheckNumberValue(model.followers, dict[@"followers"])) {
        count += 1;
    }
    if (CheckNumberValue(model.following, dict[@"following"])) {
        count += 1;
    }
    if (CheckDateValue(model.createdAt, dict[@"created_at"])) {
        count += 1;
    }
    if (CheckDateValue(model.updatedAt, dict[@"updated_at"])) {
        count += 1;
    }
    
    return count == dict.count;
}

@end
