//
//  Example2ViewController.swift
//  XZCarouselViewExample
//
//  Created by 徐臻 on 2019/3/7.
//  Copyright © 2019 mlibai. All rights reserved.
//

import UIKit
import SDWebImage
import XZKit

private let reuseIdentifier = "Cell"

class Example2ViewController: UICollectionViewController, ImageViewerDelegate, ImageViewerDataSource {
    
    let imageURLs = [
        URL(string: "http://img3.imgtn.bdimg.com/it/u=3204637472,3606476471&fm=26&gp=0.jpg")!,
        URL(string: "http://img0.imgtn.bdimg.com/it/u=1026786338,3550838642&fm=26&gp=0.jpg")!,
        URL(string: "http://img3.imgtn.bdimg.com/it/u=3204637472,3606476471&fm=26&gp=0.jpg")!,
        URL(string: "http://img1.imgtn.bdimg.com/it/u=843829727,2884188284&fm=26&gp=0.jpg")!,
        URL(string: "http://img2.imgtn.bdimg.com/it/u=1696566855,1684736675&fm=26&gp=0.jpg")!,
        URL(string: "http://img4.imgtn.bdimg.com/it/u=260532076,3589298916&fm=26&gp=0.jpg")!,
        URL(string: "http://img5.imgtn.bdimg.com/it/u=2149013970,2898954339&fm=26&gp=0.jpg")!,
        URL(string: "http://img2.imgtn.bdimg.com/it/u=2978796586,3163974224&fm=26&gp=0.jpg")!,
        URL(string: "http://img4.imgtn.bdimg.com/it/u=260532076,3589298916&fm=26&gp=0.jpg")!,
        URL(string: "http://img1.imgtn.bdimg.com/it/u=843829727,2884188284&fm=26&gp=0.jpg")!
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Example2CollectionViewCell
    
        cell.imageView.sd_setImage(with: imageURLs[indexPath.item], completed: nil);
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewer = ImageViewer.init()
        viewer.delegate              = self
        viewer.dataSource            = self
        viewer.currentIndex          = indexPath.item
        viewer.carouselView.maximumZoomScale      = 3.0
        viewer.carouselView.contentMode           = .scaleAspectFit
        viewer.carouselView.isZoomingLockEnabled  = false
        viewer.carouselView.remembersZoomingState = true
        self.present(viewer, animated: true, completion: nil);
    }
    
    func numberOfImages(in imageViewer: ImageViewer) -> Int {
        return imageURLs.count
    }
    
    func imageViewer(_ imageViewer: ImageViewer, imageView: UIImageView, loadImageAt index: Int, completion: @escaping (CGSize, Bool) -> Void) {
        imageView.sd_setImage(with: imageURLs[index], completed: { (image, _, cacheType, _) in
            completion(image?.size ?? .zero, cacheType == .none)
        })
    }
    
    func imageViewer(_ imageViewer: ImageViewer, sourceRectForImageAt index: Int) -> CGRect {
        guard let cell = collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? Example2CollectionViewCell else { return .zero }
        return cell.convert(cell.bounds, to: cell.window)
    }

    func imageViewer(_ imageViewer: ImageViewer, sourceContentModeForImageAt index: Int) -> UIView.ContentMode {
        return .scaleAspectFill
    }

}

class Example2CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
}
