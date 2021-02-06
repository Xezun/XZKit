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
            URL(string: "http://localhost/upload/files/20201206121515711.jpg")!,
            URL(string: "http://localhost/upload/files/20201206121506763.jpg")!,
            URL(string: "http://localhost/upload/files/20201206121459686.jpg")!,
            URL(string: "http://localhost/upload/files/20201206121453139.jpg")!,
            URL(string: "http://localhost/upload/files/20201206121447736.jpeg")!,
            URL(string: "http://localhost/upload/files/20201206121440187.jpg")!,
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
