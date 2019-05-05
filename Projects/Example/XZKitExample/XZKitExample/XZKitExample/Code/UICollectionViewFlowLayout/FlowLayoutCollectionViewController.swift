//
//  FlowLayoutCollectionViewController.swift
//  Example
//
//  Created by mlibai on 2018/7/14.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit

private let reuseIdentifier = "Cell"

class FlowLayoutCollectionViewController: UICollectionViewController, XZKit.UICollectionViewDelegateFlowLayout, NavigationBarCustomizable {
    
    init() {
        super.init(collectionViewLayout: XZKit.UICollectionViewFlowLayout.init())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dataArray = [[(color: UIColor, text: String, size: CGSize)]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barTintColor = .white
        self.navigationBar.title = "Flow Layout"
        self.navigationBar.backButton!.setTitle("返回", for: .normal)
        self.navigationBar.backButton!.sizeToFit()
    
        self.navigationBar.infoButton?.setTitle("设置", for: .normal)
        self.navigationBar.infoButton?.addTarget(self, action: #selector(infoButtonAction(_:)), for: .touchUpInside)
        self.navigationBar.infoButton!.sizeToFit()
        
        self.collectionView!.backgroundColor = .white
        self.collectionView!.register(FlowLayoutCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(FlowLayoutCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(FlowLayoutCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reuseIdentifier)
        
        let hots = [
            ["陆军征兵宣传片", "胡彦斌否认复合", "吴亦凡回怼虎扑", "吴亦凡音频", "王思聪", "新歌应援大赛", "陈立农"],
            ["考科目一", "身上缠满金属线", "章文回应性骚扰指控", "二哈回家", "带回女朋友", "郑爽张翰", "他都没驾照", "算不上酒驾", "情侣面对面乘共享单车", "青春斗被曝霸占女生宿舍", "在儿子失踪处摆摊年"],
            ["吴亦凡粉丝", "虎扑", "潘石屹儿子", "带带大师兄", "牌牌琦道歉", "因爱吃辞职做甜品", "放一下快递毛钱", "自家楼顶长世界最毒蘑菇", "skr"],
            ["玩奇迹暖暖", "家里有矿", "吴亦凡工作室声明", "#岁大爷长着岁的脸#", "右肾", "颗结石", "没知识会被小孩看不起", "想象中的大学生活", "什么热搜冠军都不是重要的事情才能测试出各种情况的代码和例子"],
            ["上海银行回应亿理财爆仓", "男人更易一见钟情", "别救我", "先救狗", "郑州暴雨", "哈利波特", "霍格沃兹录取信", "郑爽八月魔咒", "雪姨", "道明寺妈妈", "黄子韬", "医生手术间隙打点滴坚持", "台湾新款娃娃机", "SKT", ":", "bbq", "西虹市首富"],
            ["TFBOYS蜡像底稿泄露", "#男性憧憬的理想身材#", "祖孙三代", "吃鸡全家福", "蒋方舟", "是个男的都喜欢杉菜", "土豪梦", "自制沪A", "zhourush", "育龄妇女减约万人", "司机累了让乘客开车", "成都房管局", "章文"]
        ]
        for section in 0 ..< hots.count {
            var sections = [(UIColor, String, CGSize)]()
            for item in 0 ..< hots[section].count {
                let word = hots[section][item]
                sections.append(
                    (
                        UIColor((arc4random_uniform(0xFFFFFF) << 8) + 0xFF),
                        hots[section][item],
                        CGSize.init(width: word.count * 16, height: Int(arc4random_uniform(40) + 20))
                    )
                )
            }
            self.dataArray.append(sections)
        }
        
        //let layout = self.collectionView!.collectionViewLayout as! CollectionViewFlowLayout
        //layout.scrollDirection = .horizontal
    }
    
    @objc private func infoButtonAction(_ button: UIButton) {
        let layout = self.collectionView!.collectionViewLayout as! XZKit.UICollectionViewFlowLayout
        FlowLayoutSettingsController.show(for: layout, from: button, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataArray.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray[section].count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlowLayoutCollectionViewCell
    
        let item = dataArray[indexPath.section][indexPath.item]
        cell.contentView.backgroundColor = item.color
        cell.textLabel.text = item.text

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlowLayoutCollectionViewCell
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            view.contentView.backgroundColor = UIColor(0x2222FFFF)
            view.textLabel.text = "Header"
        case UICollectionView.elementKindSectionFooter:
            view.contentView.backgroundColor = UIColor(0xCCCCCCFF)
            view.textLabel.text = "Footer"
        default: break
        }
        
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch (collectionViewLayout as! XZKit.UICollectionViewFlowLayout).scrollDirection {
        case .horizontal:
            let item = dataArray[indexPath.section][indexPath.item]
            return CGSize(width: item.size.height, height: item.size.width)
        case .vertical:
            let item = dataArray[indexPath.section][indexPath.item]
            return item.size
        @unknown default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch (collectionViewLayout as! XZKit.UICollectionViewFlowLayout).scrollDirection {
        case .horizontal:
            return CGSize.init(width: 50, height: collectionView.bounds.width)
        case .vertical:
            return CGSize.init(width: collectionView.bounds.width, height: 50)
        @unknown default:
            fatalError()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch (collectionViewLayout as! XZKit.UICollectionViewFlowLayout).scrollDirection {
        case .horizontal:
            return CGSize.init(width: 30, height: collectionView.bounds.width)
        case .vertical:
            return CGSize.init(width: collectionView.bounds.width, height: 30)
        @unknown default:
            fatalError()
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineAlignmentForItemsAt indexPath: IndexPath) -> CollectionViewFlowLayout.LineAlignment {
//        if indexPath.line % 2 == 0 {
//            return .trailing
//        }
//        return .leading
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemAlignmentForItemAt indexPath: IndexPath) -> CollectionViewFlowLayout.InteritemAlignment {
//        if indexPath.index % 2 == 0 {
//            return .ascender
//        }
//        return .descender
//    }

}

extension FlowLayoutCollectionViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        let popoverVC = (popoverPresentationController.presentedViewController as! UINavigationController).viewControllers.first as! FlowLayoutSettingsController
        let layout = self.collectionView!.collectionViewLayout as! XZKit.UICollectionViewFlowLayout
        layout.scrollDirection = popoverVC.scrollDirection
        layout.lineAlignment = popoverVC.lineAlignment
        layout.interitemAlignment = popoverVC.interitemAlignment
    }
    
}


class FlowLayoutCollectionViewCell: UICollectionViewCell {
    
    let textLabel = UILabel.init(frame: CGRect.init(x: 0, y: 10, width: 10, height: 10))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.textColor = UIColor.white
        textLabel.frame = contentView.bounds
        textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.font = UIFont.systemFont(ofSize: 14.0)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        contentView.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


