//
//  Example1Style2ViewController.swift
//  CarouselViewExample
//
//  Created by 徐臻 on 2019/4/28.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import XZKit

class Example1Style2ViewController: UIViewController, ImageCarouselViewDelegate {
    
    @IBOutlet fileprivate weak var imageCarouselView: ImageCarouselView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageURLs = [
            URL(string: "http://fengxinju.bj01.bdysite.com/upfiles/201803/30/1962_n2.jpg")!,
            URL(string: "https://img.ithome.com/newsuploadfiles/2019/4/20190410_143544_927.jpg@wm_1,k_aW1nL3FkLnBuZw==,y_20,o_100,x_20,g_7")!,
            URL(string: "http://img0.imgtn.bdimg.com/it/u=1026786338,3550838642&fm=26&gp=0.jpg")!,
            URL(string: "http://img3.imgtn.bdimg.com/it/u=3204637472,3606476471&fm=26&gp=0.jpg")!,
            URL(string: "http://img1.imgtn.bdimg.com/it/u=843829727,2884188284&fm=26&gp=0.jpg")!,
            URL(string: "http://img2.imgtn.bdimg.com/it/u=1696566855,1684736675&fm=26&gp=0.jpg")!,
            URL(string: "http://img4.imgtn.bdimg.com/it/u=260532076,3589298916&fm=26&gp=0.jpg")!,
            URL(string: "http://img5.imgtn.bdimg.com/it/u=2149013970,2898954339&fm=26&gp=0.jpg")!,
            URL(string: "http://img2.imgtn.bdimg.com/it/u=2978796586,3163974224&fm=26&gp=0.jpg")!,
            URL(string: "http://img5.imgtn.bdimg.com/it/u=1649871572,1090852527&fm=26&gp=0.jpg")!,
            URL(string: "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1706227310,1982342322&fm=26&gp=0.jpg")!
        ]
        
        imageCarouselView.backgroundColor = .white
        imageCarouselView.clipsToBounds = false
        imageCarouselView.keepsTransitioningViews = true
        imageCarouselView.contentMode = CarouselView.extending(.scaleAspectFill, at: .bottom)
        imageCarouselView.imageURLs = imageURLs
        imageCarouselView.interitemSpacing = 10;
        
        
        // 事件代理
        imageCarouselView.delegate = self
        imageCarouselView.transitionViewHierarchy = .pageCurl
        
        imageCarouselView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settingsVC = segue.destination as? Example1SettingsViewController else { return }
        settingsVC.carouselView = self.imageCarouselView
    }
    
    func imageCarouselView(_ imageCarouselView: ImageCarouselView, imageView: UIImageView, loadImageFrom imageURL: URL, completion: @escaping (CGSize, Bool) -> Void) {
        // 设置占位图的大小。
        imageView.contentMode = .center
        imageView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        // 使用 SDWebImage 加载图片。
        imageView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "avatar"), completed: { (image, _, cacheType, _) in
            if let image = image {
                imageView.contentMode = .scaleToFill
                completion(image.size, false) // 图片加载后，调用回调更新图片的实际大小。
            } else {
                imageView.image = UIImage(named: "error") // 加载错误图片。
                completion(CGSize(width: 120.0, height: 120.0), false)
            }
        })
    }
    
}
