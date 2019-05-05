//
//  ImageTestViewController.swift
//  XZKit_Example
//
//  Created by mlibai on 2017/10/31.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit
import XZKit

class ImageTestCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    
    
}

class ImageTestViewController: UICollectionViewController {
    
    var colors: [UIColor] = [
        .black, .darkGray, .lightGray, .white,
        .gray, .red, .green, .blue,
        .cyan, .yellow, .magenta, .orange,
        .purple, .brown
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationBar.title = "UIImage"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: Foundation.IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageTestCell
        
        switch indexPath.section {
        case 0:
            cell.imageView.image = UIImage.init(filled: colors[indexPath.row]);
        case 1:
            cell.imageView.image = UIImage.init(filled: colors[indexPath.row], borderColor: UIColor.init(0x59c8d5ff))
        default:
            cell.imageView.image = UIImage.init(filled: colors[indexPath.row], borderColor: UIColor.red, cornerRadius: 20)
        }
        
        return cell
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
