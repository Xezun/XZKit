//
//  Example3WebViewController.swift
//  CarouselViewExample
//
//  Created by 徐臻 on 2019/6/6.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import WebKit

class Example3WebViewController: UIViewController, WKNavigationDelegate {
    
    deinit {
        print("VC\(index) \(self.title!): \(#function)")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "native")
    }
    
    let index: Int
    
    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var url: URL?
    
    func prepareForReusing() {
        self.url = nil
        webView.load(.init(url: URL.init(string: "about:blank")!))
    }
    
    func load(url: URL) {
        if url == self.url {
            return
        }
        self.url = url
        view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1.0)
        webView.loadHTMLString(loadingHTML(with: url), baseURL: nil)
    }
    
    var webView: WKWebView {
        return (view as! WebViewWrapperView).webView
    }
    
    override func loadView() {
        self.view = WebViewWrapperView.init(frame: UIScreen.main.bounds)
    }
    
    private lazy var messageHandler = MessageHandler.init()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        webView.configuration.userContentController.add(messageHandler, name: "native")
        let userScript = WKUserScript.init(source: """
        $(function() {
            $("html").css("backgroundColor", "#fff");
            $("div.hd[role='navigation']").hide();
            $("div.hd-tab").hide();
            $("div.edit-tab").hide();
            $("div.news-class").hide();
            $("div.head:not(:has(.rank-tab))").hide();
            $("a.open-app-a").remove();
            $("div.open-app-banner").remove();
            window.webkit.messageHandlers.native.postMessage(true);
            // function getElementTop(el) {
            //     if (el.parentElement) {
            //         return getElementTop(el.parentElement) + el.offsetTop;
            //     }
            //     return el.offsetTop;
            // }
            // var top = getElementTop($("div.swiper-wrapper[role='menubar']")[0]);
            // window.webkit.messageHandlers.native.postMessage(top);
        });
        """, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)
        webView.navigationDelegate = self;
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "返回", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("VC\(index) \(self.title!): \(#function) \(animated)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("VC\(index) \(self.title!): \(#function) \(animated)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("VC\(index) \(self.title!): \(#function) \(animated)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("VC\(index) \(self.title!): \(#function) \(animated)")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if let parent = parent {
            print("VC\(index) \(self.title!): \(#function) \(parent)")
        } else {
            print("VC\(index) \(self.title!): \(#function) nil)")
        }
        
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if let parent = parent {
            print("VC\(index) \(self.title!): \(#function) \(parent)")
        } else {
            print("VC\(index) \(self.title!): \(#function) nil)")
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            decisionHandler(.cancel)
            
            let webVC = Example3WebViewController.init(index: -1)
            webVC.title = "新闻详情"
            webVC.webView.load(navigationAction.request)
            navigationController!.pushViewController(webVC, animated: true)
        default:
            decisionHandler(.allow)
        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard let url = self.url else {
            return
        }
        self.url = nil;
        self.load(url: url)
    }
    
    class MessageHandler: NSObject, WKScriptMessageHandler {
        deinit {
            print("MessageHandler: \(#function)")
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("MessageHandler: Document was ready.")
        }
    }
    
    class WebViewWrapperView: UIView {
        deinit {
            print("WebViewWrapperView: \(#function)")
        }
        
        lazy var webView: WKWebView = {
            let webView = WKWebView.init(frame: bounds)
            if #available(iOS 9.0, *) {
                webView.allowsLinkPreview = false
            } else {
                // Fallback on earlier versions
            }
            webView.scrollView.bounces = false
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(webView)
            return webView
        }()
    }
}




fileprivate func loadingHTML(with url: URL) -> String {
    return """
    <!DOCTYPE html><html><head><meta charset="utf-8"><title>XZKit</title><meta name="apple-mobile-web-app-capable"content="yes"><meta name="viewport"content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"><style type="text/css">.loadEffect{width:100px;height:100px;position:absolute;top:50%;left:50%;margin-top:-50px;margin-left:-50px}.loadEffect span{display:inline-block;width:16px;height:16px;border-radius:50%;background:#c10619;position:absolute;-webkit-animation:load 1.04s ease infinite}@-webkit-keyframes load{0%{opacity:1}100%{opacity:0.2}}.loadEffect span:nth-child(1){left:0;top:50%;margin-top:-8px;-webkit-animation-delay:0.13s}.loadEffect span:nth-child(2){left:12px;top:12px;-webkit-animation-delay:0.26s}.loadEffect span:nth-child(3){left:50%;top:0;margin-left:-8px;-webkit-animation-delay:0.39s}.loadEffect span:nth-child(4){top:12px;right:12px;-webkit-animation-delay:0.52s}.loadEffect span:nth-child(5){right:0;top:50%;margin-top:-8px;-webkit-animation-delay:0.65s}.loadEffect span:nth-child(6){right:12px;bottom:12px;-webkit-animation-delay:0.78s}.loadEffect span:nth-child(7){bottom:0;left:50%;margin-left:-8px;-webkit-animation-delay:0.91s}.loadEffect span:nth-child(8){bottom:12px;left:12px;-webkit-animation-delay:1.04s}</style></head><body><div class="loadEffect"><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span></div></body></html><script type="text/javascript">setTimeout(function() {window.location.href="\(url.absoluteString)";}, 500);</script>
    """
}

