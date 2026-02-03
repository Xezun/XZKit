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

@interface Example05BenchmarkOperation : NSOperation
+ (Example05BenchmarkOperation *)operationWithBlock:(dispatch_block_t)block message:(NSString *)message duration:(NSTimeInterval)duration delegate:(UIViewController *)delegate;
@end

@interface Example05BenchmarkViewController () {
    NSInteger _count;
    NSOperationQueue *_queue;
}
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIButton *markButton;

@end

@implementation Example05BenchmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addLine];
    _count = 1;
    _textLabel.text = @"";
    _queue = [[NSOperationQueue alloc] init];
    _queue.qualityOfService = NSQualityOfServiceUserInteractive;
    _queue.maxConcurrentOperationCount = 1;
    
    [self addText:[NSString stringWithFormat:@"Device: %@\n", UIDevice.currentDevice.xz_productName]];
    [self addText:[NSString stringWithFormat:@"System: %@ %@\n", UIDevice.currentDevice.systemName, UIDevice.currentDevice.systemVersion]];
    [self addLine];
    
    switch (_action) {
        case Example05BenchmarkActionMark:
            [self addText:@"本功能移植自 YYModel\n"];
            break;
        case Example05BenchmarkActionTime:
            [self addText:@"执行定量代码，利用Instruments查找耗时操作\n"];
            break;
        default:
            break;
    }
    [self addLine];
}

- (void)dispatchOperation:(dispatch_block_t)block message:(NSString *)message duration:(NSTimeInterval)duration {
    [_queue addOperation:[Example05BenchmarkOperation operationWithBlock:block message:message duration:duration delegate:self]];
}

- (IBAction)markButtonAction:(UIButton *)sender {
    self.markButton.enabled = NO;
    
    [self addText:[NSString stringWithFormat:@"第 %ld 次测评\n", _count++]];
    
    switch (self.action) {
        case Example05BenchmarkActionMark: {
            [self xz_showToast:[XZToast messageToast:@"正在测评，请耐心等待"] duration:0.0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self benchmarkGithubUser];
                [self benchmarkWeiboStatus];
                self.markButton.enabled = YES;
                [self xz_hideToast:nil];
            });
            break;
        }
        case Example05BenchmarkActionTime:
            [self timeProfileUser];
            break;
        default:
            break;
    }
}

- (void)addText:(NSString *)text {
    _textLabel.text = [_textLabel.text stringByAppendingString:text];
}

- (void)addBenchmarkHeader:(NSString *)name count:(NSInteger)count {
    [self addText:@"------------------------------------\n"];
    [self addText:[NSString stringWithFormat:@"Benchmark: %@ (%ld times)  \n", name, count]];
    [self addText:@"------------------------------------\n"];
    [self addText:@"Library | decode | encode | archive \n"];
    [self addText:@"--------|--------|--------|---------\n"];
}

- (void)addBenchmarkResult:(NSString *)text decode:(NSTimeInterval)duration1 encode:(NSTimeInterval)duration2 archive:(NSTimeInterval)duration3 {
    NSString *string1 = [NSString stringWithFormat:@"%-7s", text.UTF8String];
    NSString *string2 = duration1 <= 0 ? @"        " : [NSString stringWithFormat:@"%6.2f", duration1];
    NSString *string3 = duration2 <= 0 ? @"        " : [NSString stringWithFormat:@"%6.2f", duration2];
    NSString *string4 = duration3 <= 0 ? @"        " : [NSString stringWithFormat:@"%6.2f", duration3];
    NSString *string = [NSString stringWithFormat:@"%@ | %@ | %@ | %@  \n", string1, string2, string3, string4];
    [self addText:string];
}

- (void)addBenchMarkFooter {
    [self addText:@"------------------------------------\n"];
    [self addText:@"\n"];
}

- (void)addLine {
    [self addText:@"------------------------------------\n"];
}

- (void)checkXZUserEncode {
    
}

- (void)checkXZUserDecode {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05User" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary * const _userDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([self checkGHUser:(id)[Example05YYUser yy_modelWithJSON:_userDictionary]]) {
        [self addText:@"YYModel decode verify: pass\n"];
    } else {
        [self addText:@"YYModel decode verify: fail\n"];
    }
}

- (void)checkYYUserEncode {
    
}

- (void)checkYYUserDecode {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05User" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary * const _userDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([self checkGHUser:[XZJSON decode:_userDictionary options:kNilOptions class:[Example05XZUser class]]]) {
        [self addText:@"XZJSON  decode verify: pass\n"];
    } else {
        [self addText:@"XZJSON  decode verify: fail\n"];
    }
}

- (void)benchmarkGithubUser {
    int const count = 10000;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05User" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary * const dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableArray * const holder = [NSMutableArray arrayWithCapacity:count];
    
    [self addBenchmarkHeader:@"User" count:count];
    
    NSTimeInterval duration1 = 0;
    NSTimeInterval duration2 = 0;
    NSTimeInterval duration3 = 0;
    
    /*------------------- YYModel -------------------*/
    {
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                [Example05YYUser yy_modelWithJSON:dict];
                [holder addObject:NSDate.date];
            }
        }
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    Example05YYUser *user = [Example05YYUser yy_modelWithJSON:dict];
                    [holder addObject:user];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration1 = (end - begin) * 1000;
        }
        
        Example05YYUser *user = [Example05YYUser yy_modelWithJSON:dict];
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    NSDictionary *json = [user yy_modelToJSONObject];
                    [holder addObject:json];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration2 = (end - begin) * 1000;
        }
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:NO error:nil];
                    [holder addObject:data];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration3 = (end - begin) * 1000;
        }
        
        [self addBenchmarkResult:@"YYModel" decode:duration1 encode:duration2 archive:duration3];
    }
    
    /*------------------- XZJSON -------------------*/
    {
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                [XZJSON decode:dict options:kNilOptions class:[Example05XZUser class]];
                [holder addObject:NSDate.date];
            }
        }
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    Example05XZUser *user = [XZJSON decode:dict options:kNilOptions class:[Example05XZUser class]];
                    [holder addObject:user];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration1 = (end - begin) * 1000;
        }
        
        Example05XZUser *user = [XZJSON decode:dict options:kNilOptions class:[Example05XZUser class]];
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:64];
                    [XZJSON model:user encodeIntoDictionary:json];
                    [holder addObject:json];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration2 = (end - begin) * 1000;
        }
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:NO error:nil];
                    [holder addObject:data];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration3 = (end - begin) * 1000;
        }
        
        [self addBenchmarkResult:@"XZJSON" decode:duration1 encode:duration2 archive:duration3];
    }
    
    [self addBenchMarkFooter];
}

- (void)benchmarkWeiboStatus {
    int const count = 1000;
    
    /// get json data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05WeiboStatus" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary * const dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableArray * const holder = [NSMutableArray arrayWithCapacity:count];
    
    [self addBenchmarkHeader:@"WeiboStatus" count:count];
    
    NSTimeInterval duration1 = 0;
    NSTimeInterval duration2 = 0;
    NSTimeInterval duration3 = 0;
    
    /*------------------- YYModel -------------------*/
    {
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                [Example05YYWeiboStatus yy_modelWithJSON:dict];
                [holder addObject:NSDate.date];
            }
        }
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    Example05YYWeiboStatus *feed = [Example05YYWeiboStatus yy_modelWithJSON:dict];
                    [holder addObject:feed];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration1 = (end - begin) * 1000;
        }
        
        Example05YYWeiboStatus *feed = [Example05YYWeiboStatus yy_modelWithJSON:dict];
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    NSDictionary *json = [feed yy_modelToJSONObject];
                    [holder addObject:json];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration2 = (end - begin) * 1000;
        }
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:feed requiringSecureCoding:NO error:nil];
                    [holder addObject:data];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration3 = (end - begin) * 1000;
        }
        
        [self addBenchmarkResult:@"YYModel" decode:duration1 encode:duration2 archive:duration3];
    }

    /*------------------- XZJSON -------------------*/
    {
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                [XZJSON decode:dict options:kNilOptions class:[Example05XZWeiboStatus class]];
                [holder addObject:NSDate.date];
            }
        }
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    Example05XZWeiboStatus *feed = [XZJSON decode:dict options:kNilOptions class:[Example05XZWeiboStatus class]];
                    [holder addObject:feed];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration1 = (end - begin) * 1000;
        }
        
        Example05XZWeiboStatus *feed = [XZJSON decode:dict options:kNilOptions class:[Example05XZWeiboStatus class]];
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    NSMutableDictionary *json = [NSMutableDictionary dictionary];
                    [XZJSON model:feed encodeIntoDictionary:json];
                    [holder addObject:json];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration2 = (end - begin) * 1000;
        }
        
        {
            [holder removeAllObjects];
            NSTimeInterval begin = CACurrentMediaTime();
            @autoreleasepool {
                for (int i = 0; i < count; i++) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:feed requiringSecureCoding:NO error:nil];
                    [holder addObject:data];
                }
            }
            NSTimeInterval end = CACurrentMediaTime();
            duration3 = (end - begin) * 1000;
        }
        
        [self addBenchmarkResult:@"XZJSON" decode:duration1 encode:duration2 archive:duration3];
    }
    
    [self addBenchMarkFooter];
}

- (void)timeProfileUser {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05User" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    int count = 10000;
    void (^YYEncodingTest)(void) = ^{
        NSMutableArray *holder = [NSMutableArray arrayWithCapacity:count * 2];
        Example05YYUser *user = [Example05YYUser yy_modelWithJSON:json];
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [user yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
    };
    
    void (^YYDecodingTest)(void) = ^{
        NSMutableArray *holder = [NSMutableArray arrayWithCapacity:count * 2];
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05YYUser *user = [Example05YYUser yy_modelWithJSON:json];
                [holder addObject:user];
            }
        }
    };
    
    void (^XZEncodingTest)(void) = ^{
        NSMutableArray *holder = [NSMutableArray arrayWithCapacity:count * 2];
        Example05XZUser *user = [XZJSON decode:json options:kNilOptions class:[Example05XZUser class]];
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:64];
                [XZJSON model:user encodeIntoDictionary:json];
                [holder addObject:json];
            }
        }
    };
    
    void (^XZDecodingTest)(void) = ^{
        NSMutableArray *holder = [NSMutableArray arrayWithCapacity:count * 2];
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05XZUser *user = [XZJSON decode:json options:kNilOptions class:[Example05XZUser class]];
                [holder addObject:user];
            }
        }
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        YYDecodingTest();
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            YYEncodingTest();
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XZDecodingTest();
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    XZEncodingTest();
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.markButton.enabled = YES;
                    });
                });
            });
        });
    });
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
                NSString *type = ((Example05YYUser *)user).type;
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
        Example05YYUser *yyUser = [Example05YYUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZUser class]];
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
                UInt32 num = ((Example05YYUser *)user).followers;
                if (num != 100) {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %u\n",(unsigned int)num]];
                } else {
                    [self addText:[NSString stringWithFormat:@"✅ property is %u\n",(unsigned int)num]];
                }
            }
        };
        
        // YYModel
        Example05YYUser *yyUser = [Example05YYUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZUser class]];
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
                NSDate *date = ((Example05YYUser *)user).updatedAt;
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
        Example05YYUser *yyUser = [Example05YYUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZUser class]];
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
                NSValue *valur = ((Example05YYUser *)user).test;
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
        Example05YYUser *yyUser = [Example05YYUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZUser class]];
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

- (BOOL)checkGHUser:(Example05XZUser *)model {
    NSInteger count = 0;
    
    NSString *path = [NSBundle.mainBundle pathForResource:@"Example05User" ofType:@"json"];
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

@implementation Example05BenchmarkOperation {
    NSString *_message;
    dispatch_block_t _block;
    BOOL _isExecuting;
    BOOL _isFinished;
    UIViewController * __weak _delegate;
    NSTimeInterval _duration;
}

+ (Example05BenchmarkOperation *)operationWithBlock:(dispatch_block_t)block message:(NSString *)message duration:(NSTimeInterval)duration delegate:(UIViewController *)delegate {
    Example05BenchmarkOperation *operation = [[self alloc] init];
    if (self) {
        operation->_block = block;
        operation->_message = message;
        operation->_delegate = delegate;
        operation->_duration = duration;
    }
    return operation;
}

- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_message) {
            [self->_delegate xz_showToast:[XZToast sharedToast:(XZToastStyleMessage) text:self->_message] duration:self->_duration];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self->_block();
            
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            self->_isExecuting = NO;
            self->_isFinished = YES;
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
        });
    });
}

- (BOOL)isFinished {
    return _isFinished;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

@end
