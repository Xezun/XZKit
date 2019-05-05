//
//  ColorTestCollectionViewController.swift
//  XZKit_Example
//
//  Created by mlibai on 2017/11/1.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

class ColorTestCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel1: UILabel!
    
    @IBOutlet weak var textLabel2: UILabel!
    
    @IBOutlet weak var statusButton: UIButton!
    
    var isRight: Bool {
        get {
            return statusButton.isEnabled
        }
        set {
            statusButton.isEnabled = newValue
        }
    }
    
}

private let reuseIdentifier = "cell"

class ColorTestCollectionViewController: UICollectionViewController {
    
    var colors: [(str1: String, str2: String, color: UIColor, isRight: Bool)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationBar.title = "UIColor"
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 40) / 3, height: 100);
        
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        for _ in 0 ..< 99 {
            let rgba = arc4random_uniform(0xFFFFFF)
            let str1 = String.init(format: "#%06lXFF", rgba);
            let color = UIColor.init(str1)
            let str2 = String.init(format: "#%08lX", color.rgbaValue);
            colors.append((str1, str2, color, str2 == str1))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ColorTestCell
    
        let item = colors[indexPath.item]
        cell.backgroundColor = item.color
        cell.textLabel1.text = item.str1
        cell.textLabel2.text = item.str2
        cell.isRight = item.isRight
    
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        guard let color = cell.backgroundColor else { return }
        print(String.init(format: "#%08lX", color.rgbaValue))
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
