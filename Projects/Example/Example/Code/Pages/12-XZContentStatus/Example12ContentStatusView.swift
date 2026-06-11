//
//  Example12ContentStatusView.swift
//  Example
//
//  Created by Xezun on 2026/6/10.
//

import UIKit
import XZKit

protocol Example12ContentStatusViewDelegate: AnyObject {
    
    func loadingView(_ loadingView: Example12ContentStatusView, didSelectLoadResult contentStatus: XZContentStatus?) -> Void
    
}

class Example12ContentStatusView: UIView {
    
    weak var delegate: Example12ContentStatusViewDelegate?
    
    convenience init(delegate: Example12ContentStatusViewDelegate) {
        self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        self.delegate = delegate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let vStack = UIStackView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        vStack.axis = .vertical
        addSubview(vStack)
        
        do {
            let indicatorView = UIActivityIndicatorView.init(style: .large)
            indicatorView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
            indicatorView.startAnimating()
            vStack.addArrangedSubview(indicatorView)
            
            let messageLabel = UILabel.init()
            messageLabel.textAlignment = .center
            messageLabel.font = .systemFont(ofSize: 17.0)
            messageLabel.textColor = .gray
            messageLabel.numberOfLines = 3
            messageLabel.text = "当前数据加载中\n\n加载结果，点击下面的按钮"
            vStack.addArrangedSubview(messageLabel)
        }
        
        do {
            let buttonStack = UIStackView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            buttonStack.axis = .horizontal
            buttonStack.distribution = .fillEqually
            buttonStack.spacing = 10.0
            vStack.addArrangedSubview(buttonStack)
            
            do {
                let successButton = UIButton(type: .system)
                successButton.frame = CGRect.init(x: 0, y: 100, width: 50, height: 40)
                successButton.layer.cornerRadius = 6.0
                successButton.layer.borderColor  = UIColor.lightGray.cgColor
                successButton.layer.borderWidth  = 1.0;
                successButton.titleLabel?.font = .systemFont(ofSize: 17.0)
                successButton.setTitle("成功", for: .normal)
                successButton.setTitleColor(.lightGray, for: .normal)
                buttonStack.addArrangedSubview(successButton)
                
                successButton.addTarget(self, action: #selector(successButtonAction(_:)), for: .touchUpInside)
            }
            
            do {
                let emptyButton = UIButton(type: .system)
                emptyButton.frame = CGRect.init(x: 33, y: 100, width: 50, height: 40)
                emptyButton.layer.cornerRadius = 6.0
                emptyButton.layer.borderColor  = UIColor.lightGray.cgColor
                emptyButton.layer.borderWidth  = 1.0;
                emptyButton.titleLabel?.font = .systemFont(ofSize: 17.0)
                emptyButton.setTitle("无内容", for: .normal)
                emptyButton.setTitleColor(.lightGray, for: .normal)
                buttonStack.addArrangedSubview(emptyButton)
                
                emptyButton.addTarget(self, action: #selector(emptyButtonAction(_:)), for: .touchUpInside)
            }
            
            do {
                let failureButton = UIButton(type: .system)
                failureButton.frame = CGRect.init(x: 67, y: 100, width: 50, height: 40)
                failureButton.layer.cornerRadius = 6.0
                failureButton.layer.borderColor  = UIColor.lightGray.cgColor
                failureButton.layer.borderWidth  = 1.0;
                failureButton.titleLabel?.font = .systemFont(ofSize: 17.0)
                failureButton.setTitle("失败", for: .normal)
                failureButton.setTitleColor(.lightGray, for: .normal)
                buttonStack.addArrangedSubview(failureButton)
                
                failureButton.addTarget(self, action: #selector(failureButtonAction(_:)), for: .touchUpInside)
            }
        }
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: self.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            vStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            vStack.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: 240, height: 200)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 240, height: 200)
    }
    
    @objc func successButtonAction(_ sender: UIButton) {
        delegate?.loadingView(self, didSelectLoadResult: nil)
    }
    
    @objc func failureButtonAction(_ sender: UIButton) {
        delegate?.loadingView(self, didSelectLoadResult: .error)
    }
    
    @objc func emptyButtonAction(_ sender: UIButton) {
        delegate?.loadingView(self, didSelectLoadResult: .empty)
    }
    
}
