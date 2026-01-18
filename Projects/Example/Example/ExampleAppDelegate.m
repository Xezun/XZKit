//
//  ExampleAppDelegate.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ExampleAppDelegate.h"
@import XZKit;
@import OSLog;

@interface ExampleAppDelegate ()

@end

@implementation ExampleAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    XZLog(@"App (%@) was launched: %@", XZLogSystem.defaultLogSystem.domain, launchOptions);
    
    
    XZLog(@"double => %s", @encode(double));
    XZLog(@"long double => %s", @encode(long double));
    XZLog(@"long => %s", @encode(long));
    XZLog(@"long long => %s", @encode(long long));
    XZLog(@"BOOL => %s", @encode(BOOL));
    XZLog(@"bool => %s", @encode(bool));
    XZLog(@"void => %s", @encode(void));
    XZLog(@"char * => %s", @encode(char *));
    XZLog(@"SEL => %s", @encode(SEL));
    XZLog(@"void * => %s", @encode(void *));
    XZLog(@"int[0] => %s", @encode(int[0]));
    XZLog(@"Class => %s", @encode(Class));
    XZLog(@"NSObject => %s", @encode(NSObject));
    XZLog(@"ExampleAppDelegate => %s", @encode(ExampleAppDelegate));
    XZLog(@"NSObject * => %s", @encode(NSObject *));
    XZLog(@"ExampleAppDelegate * => %s", @encode(ExampleAppDelegate *));
    XZLog(@"id => %s", @encode(id));
    
    XZLog(@"char[1] => %s", @encode(char[1]));
    
    struct Foobar {
        int a: 0x20;
        int c: 16;
        int b: 16;
    };
    
    XZLog(@"struct Foobar => %s", @encode(struct Foobar));
    exit(0);
    for (int i = 0; i < CHAR_MAX; i++) {
        XZObjcType *type = [XZObjcType typeForType:(XZStdcType)i];
        if (type) {
            NSLog(@"%c => %@", i, type);
        } else {
            NSLog(@"%c is not a type", i);
        }
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didChangeLanguageNotification:) name:XZLocaleDidChangePreferredLanguageNotification object:nil];
    
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)didChangeLanguageNotification:(NSNotification *)notification {
    UIWindow *window = _window;
    
    CGRect const bounds = UIScreen.mainScreen.bounds;
    
    UIViewController *rootVC = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;

    _window = [[UIWindow alloc] initWithFrame:bounds];
    _window.backgroundColor = UIColor.whiteColor;
    _window.rootViewController = rootVC;
    [_window makeKeyAndVisible];
    
    _window.layer.shadowColor = UIColor.blackColor.CGColor;
    _window.layer.shadowOpacity = 0.5;
    _window.layer.shadowRadius = 5.0;
    _window.windowLevel = window.windowLevel + 1;
    _window.frame = CGRectOffset(bounds, bounds.size.height, 0);
    
    [UIView animateWithDuration:0.5 animations:^{
        self->_window.frame = bounds;
    } completion:^(BOOL finished) {
        window.hidden = YES;
        self->_window.layer.shadowColor = nil;
    }];
}



@end
