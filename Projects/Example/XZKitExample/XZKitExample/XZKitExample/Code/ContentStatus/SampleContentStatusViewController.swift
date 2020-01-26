//
//  SampleContentStatusViewController.swift
//  Example
//
//  Created by mlibai on 2018/4/3.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit


class SampleContentStatusView: UIView, ContentStatusRepresentable {
    
}

class SampleContentStatusViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.hidesBottomBarWhenPushed = true
    }
    
    override func loadView() {
        let view = SampleContentStatusView.init(frame: UIScreen.main.bounds)
        
        view.setTitle("Content is empty now", for: .empty)
        view.setImage(UIImage(named: "ImageEmpty"), for: .empty)
        
        view.setTitle("Content is loading now", for: .loading)
        view.setImage(UIImage(named: "ImageLoading"), for: .loading)
        
        view.contentStatus = .loading
        
        self.view = view
    }
    
    var contentView: SampleContentStatusView {
        return view as! SampleContentStatusView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationBar.title = "ContentStatusRepresentable"
        
        self.contentView.backgroundColor = UIColor.white
        
        contentView.setImage(UIImage(named: "img_empty"), for: .empty)
        contentView.setTitle("没有了...", for: .empty)
        contentView.setTitleColor(UIColor.gray, for: .empty)
        contentView.setTitleFont(UIFont.systemFont(ofSize: 12.0), for: .empty)
        contentView.setTitleInsets(EdgeInsets.init(top: 5, leading: 0, bottom: -5, trailing: 0), for: .empty)
        
        let image = UIImage.animatedImageNamed("gif_searching_", duration: 1.2)
        contentView.setImage(image, for: .loading)
        contentView.setTitle("加载中...", for: .loading)
        contentView.setTitleColor(UIColor(0x476eadff), for: .loading)
        contentView.setTitleFont(UIFont.systemFont(ofSize: 12.0), for: .loading)
        contentView.setTitleInsets(EdgeInsets.init(top: 10, leading: 0, bottom: -10, trailing: 0), for: .loading)
        
        contentView.setImage(UIImage(named: "img_404"), for: .error)
        contentView.setTitle("找不到...", for: .error)
        contentView.setTitleColor(UIColor(0xc73420ff), for: .error)
        contentView.setTitleFont(UIFont.systemFont(ofSize: 12.0), for: .error)
        contentView.setTitleInsets(EdgeInsets.init(top: 5, leading: 0, bottom: -5, trailing: 0), for: .error)
        
        self.contentView.contentStatus = .empty
        
        self.contentView.addTarget(self, action: #selector(emptyAction(_:)), for: .empty)
        self.contentView.addTarget(self, action: #selector(loadingAction(_:)), for: .loading)
        self.contentView.addTarget(self, action: #selector(errorAction(_:)), for: .error)
    }
    
    @objc private func emptyAction(_ view: UIView) {
        contentView.contentStatus = .loading
    }
    
    @objc private func loadingAction(_ view: UIView) {
        contentView.contentStatus = .error
    }
    
    @objc private func errorAction(_ view: UIView) {
        contentView.contentStatus = .empty
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
