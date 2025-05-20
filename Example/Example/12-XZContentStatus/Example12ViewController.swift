//
//  Example12ViewController.swift
//  Example
//
//  Created by Xezun on 2025/1/5.
//

import UIKit
import XZContentStatus
import XZExtensions
import XZTextImageView
import XZToast

class Example12ViewController: UIViewController, XZContentStatusRepresentable {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let empty = self.configuration(for: .empty)
        empty.view.backgroundColor = .systemGray6
        empty.setText("暂无内容，请稍后查看", for: .normal)
        empty.setTextColor(.blue, for: .normal)
        empty.setImage(UIImage(named: "ex-12-empty"), for: .normal)
        empty.addTarget(self, action: #selector(didClickEmptyStatus(_:)), for: .touchUpInside)
        
        let loading = self.configuration(for: .loading)
        let loadingView = Example12LoadingView.init()
        loadingView.backgroundColor = .systemGray6
        loadingView.successButton.addTarget(self, action: #selector(successButtonAction(_:)), for: .touchUpInside)
        loadingView.emptyButton.addTarget(self, action: #selector(emptyButtonAction(_:)), for: .touchUpInside)
        loadingView.failureButton.addTarget(self, action: #selector(failureButtonAction(_:)), for: .touchUpInside)
        loading.view = loadingView
        
        let error = self.configuration(for: .error)
        error.view.backgroundColor = .systemGray6
        error.setText("网络不给力，请重试", for: .normal)
        error.setTextColor(.red, for: .normal)
        error.setImage(UIImage(named: "ex-12-error"), for: .normal)
        error.addTarget(self, action: #selector(didClickErrorStatus(_:)), for: .touchUpInside)
        
        contentStatus = .empty
    }
    
    @IBAction func resetButtonAction(_ sender: UIBarButtonItem) {
        self.contentStatus = .empty
    }
    
    @objc func didClickEmptyStatus(_ sender: Any) {
        contentStatus = .loading
    }
    
    @objc func didClickErrorStatus(_ sender: Any) {
        contentStatus = .loading
    }
    
    @objc func successButtonAction(_ sender: Any) {
        self.contentStatus = .default
        showToast(.message("页面加载成功"))
    }
    
    @objc func failureButtonAction(_ sender: Any) {
        self.contentStatus = .error
    }
    
    @objc func emptyButtonAction(_ sender: Any) {
        self.contentStatus = .empty
    }

}


class Example12LoadingView: UIView {
    
    let indicatorView = UIActivityIndicatorView.init(style: .large)
    
    let messageLabel = UILabel.init()
    
    let failureButton = UIButton(type: .system)
    let emptyButton = UIButton(type: .system)
    let successButton = UIButton(type: .system)
    
    
    override init(frame: CGRect) {
        super.init(frame: .init(x: 0, y: 0, width: 140, height: 140))
        
        indicatorView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        addSubview(indicatorView)
        
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 17.0)
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 3
        messageLabel.text = "数据加载中\n\n请点击下发按钮，选择加载结果"
        addSubview(messageLabel)
        
        successButton.frame = CGRect.init(x: 0, y: 100, width: 50, height: 40)
        successButton.layer.cornerRadius = 6.0
        successButton.layer.borderColor  = UIColor.green.cgColor
        successButton.layer.borderWidth  = 1.0;
        successButton.titleLabel?.font = .systemFont(ofSize: 17.0)
        successButton.setTitle("成功", for: .normal)
        successButton.setTitleColor(.green, for: .normal)
        addSubview(successButton)
        
        emptyButton.frame = CGRect.init(x: 33, y: 100, width: 50, height: 40)
        emptyButton.layer.cornerRadius = 6.0
        emptyButton.layer.borderColor  = UIColor.blue.cgColor
        emptyButton.layer.borderWidth  = 1.0;
        emptyButton.titleLabel?.font = .systemFont(ofSize: 17.0)
        emptyButton.setTitle("无内容", for: .normal)
        emptyButton.setTitleColor(.blue, for: .normal)
        addSubview(emptyButton)
        
        failureButton.frame = CGRect.init(x: 67, y: 100, width: 50, height: 40)
        failureButton.layer.cornerRadius = 6.0
        failureButton.layer.borderColor  = UIColor.red.cgColor
        failureButton.layer.borderWidth  = 1.0;
        failureButton.titleLabel?.font = .systemFont(ofSize: 17.0)
        failureButton.setTitle("失败", for: .normal)
        failureButton.setTitleColor(.red, for: .normal)
        addSubview(failureButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: 140, height: 140)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 140, height: 140)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window == nil {
            indicatorView.stopAnimating()
        } else {
            indicatorView.startAnimating()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds.inset(by: self.safeAreaInsets)
        indicatorView.frame = CGRect.init(x: bounds.midX - 50.0, y: bounds.midY - 100, width: 100, height: 100)
        
        let size = messageLabel.sizeThatFits(bounds.size)
        messageLabel.frame  = CGRect.init(x: bounds.midX - size.width * 0.5, y: bounds.midY, width: size.width, height: size.height);
        
        successButton.frame = CGRect.init(x: bounds.midX - 40.0 - 10.0 - 80.0, y: bounds.midY + size.height + 20.0, width: 80.0, height: 30.0)
        emptyButton.frame   = CGRect.init(x: bounds.midX - 40.0              , y: bounds.midY + size.height + 20.0, width: 80.0, height: 30.0)
        failureButton.frame = CGRect.init(x: bounds.midX + 40.0 + 10.0       , y: bounds.midY + size.height + 20.0, width: 80.0, height: 30.0)
    }
    
}
