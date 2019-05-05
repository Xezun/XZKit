//
//  SampleCarouselViewController.swift
//  Example
//
//  Created by mlibai on 2018/1/8.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit
import SDWebImage

class SampleImageCarouselViewController: UIViewController, ImageCarouselViewDelegate {
    
    let imageCarousel: ImageCarouselView = ImageCarouselView.init(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationBar.title = "ImageCarouselView"
        
        automaticallyAdjustsScrollViewInsets = false;
        view.backgroundColor = UIColor.white
        
        imageCarousel.frame = view.bounds//CGRect.init(x: 0, y: 100, width: view.bounds.width, height: 300)
        imageCarousel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageCarousel)
        
        let imageURLs: [URL] = [
            URL(string: "http://funsbar.image.alimmdn.com/image/E4B7CEB3157C4A6CA220C7103C7D99B0.png")!,
            URL(string: "http://funsbar.image.alimmdn.com/image/74928BE46AC145A1970B80579527A8FE.png")!,
            URL(string: "http://funsbar.image.alimmdn.com/image/F575E3635B534634AC3B29BA0EE53615.png")!,
            URL(string: "http://funsbar.image.alimmdn.com/image/653DDFE15B584828BDB7515FC7FF9D84.png")!,
            URL(string: "http://funsbar.image.alimmdn.com/image/193F40B0D0714BDAB8AAFED0864858C4.png")!,
            URL(string: "http://funsbar.image.alimmdn.com/image/15C02EFEFB564A6B92E6FD2B8FCF7EAA.png")!,
            URL(string: "http://funsbar.image.alimmdn.com/image/A63F9569A5404AB3A4D815B994C37BF6.png")!,
            URL(string: "http://funsbar.image.alimmdn.com/image/5E32D37B29DD4573ABE7F30FB76DA56E.png")!,
            URL(string: "http://funsbar.image.alimmdn.com/image/815BB34103E84A1FA3921471453C42B0.png")!
        ]
        
        let images: [UIImage] = [
            UIImage(named: "20170704142100")!, UIImage(named: "20170704142101")!,
            UIImage(named: "20170704142102")!, UIImage(named: "20170704142103")!,
            UIImage(named: "20170704142104")!, UIImage(named: "20170704142105")!,
            UIImage(named: "20170704142106")!, UIImage(named: "20170704142107")!
        ]
        
        
        self.imageCarousel.minimumZoomScale = 0.3;
        self.imageCarousel.maximumZoomScale = 3.0;
        // self.imageCarousel.timeInterval = 3.0;
        
        
        self.imageCarousel.images = images;
        self.imageCarousel.imageURLs = imageURLs;
        
        self.imageCarousel.delegate = self
        
        self.imageCarousel.isZoomingLockEnabled = false
    }

    func carouselView(_ carouselView: CarouselView, didShowViewAt index: Int) {
        XZLog("Did Show View at \(index)")
    }
    
    func imageCarouselView(_ imageCarouselView: ImageCarouselView, imageView: UIImageView, loadImageFrom imageURL: URL, completion: @escaping (CGSize, Bool) -> Void) {
        imageView.sd_setImage(with: imageURL, placeholderImage: imageView.image, completed: { (image, _, _, _) in
            completion(image?.size ?? .zero, false);
        })
    }

}
