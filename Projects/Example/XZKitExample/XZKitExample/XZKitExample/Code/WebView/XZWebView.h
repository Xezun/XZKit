//
//  XZWebView.h
//  Pods
//
//  Created by mlibai on 2017/7/10.
//
//

#import <UIKit/UIKit.h>

@class JSContext, XZWebView, NSURLRequest, JSValue;
@protocol JSExport;

NS_SWIFT_NAME(WebViewDelegate)
@protocol XZWebViewDelegate <UIWebViewDelegate>

@optional

/**
 当 JS 执行发生异常时，此方法会被调用。WebView 的代理会收到此方法，遵循 XZWebViewDelegate 协议即可。

 @param webView The WebView which error is occured.
 @param expection The expection.
 */
- (void)webView:(nonnull XZWebView *)webView didCatchAnException:(nullable JSValue *)expection;

@end

NS_SWIFT_NAME(WebView)
@interface XZWebView : UIWebView

/** 所有已注入的对象。 */
@property (nonatomic, copy, nonnull, readonly) NSDictionary<NSString *, id> *allExportedObjects;

/**
 WebView 初始化 JavaScript 环境后此方法会被调用。默认情况下，此方法向 JavaScript 环境注入已注册的对象。

 @param context JavaScript Context Object.
 */
- (void)didCreateJavaScriptContext:(nonnull JSContext *)context;

/// 将一个对象注入到 WebView 的 JS 环境中。
///
/// @note 1. WebView 将强引用此对象，需防止循环引用。
/// @note 2. 可以注入 `objc_block` 或 JSExport 对象。
/// @note 3. 在 Swift 中，闭包需声明为 `\@convention(block)` 类型。
///
/// @param object An Object conforms to JSExport or an ObjC block.
/// @param interface The interface name to JavaScript.
- (void)setObject:(nullable id)object forJavaScriptInterface:(nonnull NSString *)interface;

/**
 获取已注入到 WebView 中的接口对象。

 @param interface The name of JavaScript interface.
 @return The object that is registed with the name.
 */
- (nullable id)objectForJavaScriptInterface:(nonnull NSString *)interface;

@end


@class /*WebView, */WebFrame;
@interface NSObject (XZWebViewJavaScriptExtended)

/**
 此方法用于拦截 UIWebView 的 JSContext 创建事件。

 @param webView WebView 对象（UIKit 私有类）
 @param context JSContext 对象
 @param frame WebFrame 对象
 */
- (void)xz_webView:(nonnull id)webView didCreateJavaScriptContext:(nonnull JSContext *)context forFrame:(nonnull WebFrame *)frame;

@end
