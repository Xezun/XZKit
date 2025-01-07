//
//  Example12ViewController.swift
//  Example
//
//  Created by 徐臻 on 2025/1/5.
//

import UIKit
import XZContentStatus

class Example12ViewController: UIViewController, XZContentStatusRepresentable {

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle("暂无内容，请稍后查看", for: .empty)
        setTitle("正在加载，请稍后", for: .loading)
        setTitle("网络不给力，请重试", for: .error)
        
        setImage(UIImage(named: "ex-12-empty"), for: .empty)
        setImage(UIImage(named: "ex-12-loading"), for: .loading)
        setImage(UIImage(named: "ex-12-error"), for: .error)
        
        addTarget(self, action: #selector(emptyStatusViewAction(_:)), for: .empty)
        addTarget(self, action: #selector(loadingStatusViewAction(_:)), for: .loading)
        addTarget(self, action: #selector(errorStatusViewAction(_:)), for: .error)
        
        contentStatus = .empty
    }
    
    @objc func emptyStatusViewAction(_ sender: XZContentStatusView) {
        contentStatus = .loading
    }
    
    @objc func loadingStatusViewAction(_ sender: XZContentStatusView) {
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
    }
    
    @objc func errorStatusViewAction(_ sender: XZContentStatusView) {
        contentStatus = .loading
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
