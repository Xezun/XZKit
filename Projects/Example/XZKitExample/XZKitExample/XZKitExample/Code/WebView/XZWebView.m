//
//  XZWebView.m
//  Pods
//
//  Created by mlibai on 2017/7/10.
//
//

#import "XZWebView.h"

@import ObjectiveC;
@import JavaScriptCore;

@interface XZWebView () {
    NSMutableDictionary<NSString *, id> *_allExportedObjects;
}

/**
 弱引用所有已创建的 JSContext，供注入对象使用。
 */
@property (nonatomic, strong, nonnull, readonly) NSHashTable<JSContext *> *allContext;

@end

@implementation XZWebView

@synthesize allExportedObjects = _allExportedObjects;

+ (NSHashTable<XZWebView *> *)allWebViews {
    static NSHashTable *_allWebViews = nil;
    if (_allWebViews != nil) {
        return _allWebViews;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _allWebViews = [NSHashTable weakObjectsHashTable];
    });
    return _allWebViews;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self XZ_didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self XZ_didInitialize];
    }
    return self;
}

- (void)XZ_didInitialize {
    _allExportedObjects = [NSMutableDictionary dictionary];
    _allContext = [NSHashTable weakObjectsHashTable];
    [[XZWebView allWebViews] addObject:self];
}

- (void)didCreateJavaScriptContext:(JSContext *)context {
    __weak XZWebView *webView = self;
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        id<XZWebViewDelegate> delegate = (id<XZWebViewDelegate>)webView.delegate;
        if ([delegate respondsToSelector:@selector(webView:didCatchAnException:)]) {
            [delegate webView:webView didCatchAnException:value];
        }
    }];
    [_allExportedObjects enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        [context setObject:obj forKeyedSubscript:key];
    }];
}

- (void)setObject:(nullable id)object forJavaScriptInterface:(nonnull NSString *)interface {
    _allExportedObjects[interface] = object;
    for (JSContext *context in _allContext) {
        [context setObject:object forKeyedSubscript:interface];
    }
}

- (nullable id)objectForJavaScriptInterface:(nonnull NSString *)interface {
    return _allExportedObjects[interface];
}


@end




#import "ObjectiveC.h"

@protocol _XZWebViewJavaScriptSupporting <NSObject>
- (void)webView:(id)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame;
@end

@implementation NSObject (XZWebViewJavaScriptExtended)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xz_objc_class_exchangeMethodImplementations([NSObject class], @selector(webView:didCreateJavaScriptContext:forFrame:), @selector(xz_webView:didCreateJavaScriptContext:forFrame:));
    });
}

- (void)xz_webView:(id)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame {
    if (![context isKindOfClass:[JSContext class]]) {
        NSLog(@"`%s` is called, but the context is not a JSContext.", __func__);
        return;
    }
    
    static NSString *const XZ_WEBVIEW_OBJECT_ID_KEY = @"XZ_WEBVIEW_OBJECT_ID_KEY";
    static NSInteger XZ_WEBVIEW_ID = 0;
    
    // 在 context 中注入变量。
    [context setObject:@(XZ_WEBVIEW_ID++) forKeyedSubscript:XZ_WEBVIEW_OBJECT_ID_KEY];
    
    // 遍历所有注册的 UIWebView 从中取出 ObjectID 如果有和当前 context 相同的，则发送消息。
    for (XZWebView *webView in [XZWebView allWebViews]) {
        NSInteger tmpID = [[webView stringByEvaluatingJavaScriptFromString:XZ_WEBVIEW_OBJECT_ID_KEY] integerValue];
        if (tmpID == XZ_WEBVIEW_ID) {
            [webView.allContext addObject:context];
            [webView didCreateJavaScriptContext:context];
            break;
        }
    }
}

@end
