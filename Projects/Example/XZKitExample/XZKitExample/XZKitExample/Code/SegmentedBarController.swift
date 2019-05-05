//
//  SegmentedBarController.swift
//  XZKit
//
//  Created by mlibai on 2017/7/17.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit
import XZKit


class SegmentedBarController: UIViewController {
    
    let segmentedView = SegmentedBar()
    
    @IBOutlet weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func resetAction(_ sender: Any) {
        
    }
    
    @objc func contentStatusAction(_ view: UIView) -> Void {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func contentStatusViewWasTouchedUpInside(_ view: ContentStatusRepresentable) {
//        print(view.contentStatus)
//        
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func errorButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func loadingButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func emptyButtonAction(_ sender: Any) {
        
    }
    
}


extension SegmentedBarController: SegmentedBarDelegate {
    
    func segmentedBar(_ segmentedBar: SegmentedBar, widthForItemAt index: Int) -> CGFloat {
        return 100
    }
    
    func segmentedBar(_ segmentedBar: SegmentedBar, didSelectItemAt index: Int) {
        print("select index: \(index)")
    }
    
}

extension SegmentedBarController: SegmentedBarDataSource {
    
    func numberOfItemsInSegmentedBar(_ segmentedBar: SegmentedBar) -> Int {
        return 10
    }
    
    func segmentedBar(_ segmentedBar: SegmentedBar, viewForItemAt index: Int, reusing view: SegmentedBar.ItemView?) -> SegmentedBar.ItemView {
        var itemView: TextSegmentItemView! = view as? TextSegmentItemView
        if itemView == nil {
            itemView = TextSegmentItemView(frame: CGRect(x: 0, y: 0, width: 100, height: 49))
        }
        itemView.textLabel.text = "\(index)"
        
        return itemView
    }
}

class TextSegmentItemView: SegmentedBar.ItemView {
    let textLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.frame = self.bounds
        textLabel.textAlignment = .center
        contentView.addSubview(textLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                textLabel.textColor = UIColor.red
            } else {
                textLabel.textColor = UIColor.black
            }
        }
    }
    
}






