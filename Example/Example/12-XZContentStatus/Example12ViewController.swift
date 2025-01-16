//
//  Example12ViewController.swift
//  Example
//
//  Created by Xezun on 2025/1/5.
//

import UIKit
import XZContentStatus
import XZExtensions

class Example12ViewController: UIViewController, XZContentStatusRepresentable {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundColor(rgb(0xfffafa), for: .default)

        setTitle("暂无内容，请稍后查看", for: .empty)
        setTitleColor(.blue, for: .empty)
        setTitle("正在加载，请稍后", for: .loading)
        setTitleColor(.green, for: .loading)
        setTitle("网络不给力，请重试", for: .error)
        setTitleColor(.red, for: .error)
        
        setImage(UIImage(named: "ex-12-empty"), for: .empty)
        setImage(UIImage(named: "ex-12-loading"), for: .loading)
        setImage(UIImage(named: "ex-12-error"), for: .error)
        
        contentStatusView.addTarget(self, action: #selector(contentStatusViewAction(_:)), for: .touchUpInside)
        contentStatus = .empty
    }
    
    @objc func contentStatusViewAction(_ sender: XZContentStatusView) {
        switch sender.contentStatus {
        case .empty:
            contentStatus = .loading
        case .loading:
            let alert = UIAlertController.init(title: "请选择加载结果", message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "成功", style: .default, handler: { _ in
                self.contentStatus = .default
            }))
            alert.addAction(.init(title: "失败", style: .destructive, handler: { _ in
                self.contentStatus = .error
            }))
            alert.addAction(.init(title: "无内容", style: .default, handler: { _ in
                self.contentStatus = .empty
            }))
            self.present(alert, animated: true)
        case .error:
            contentStatus = .loading
        default:
            break
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
