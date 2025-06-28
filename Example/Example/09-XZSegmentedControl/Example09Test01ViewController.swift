//
//  Example09Test01ViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/12.
//

import UIKit
import XZJSON
import XZMocoa
import XZSegmentedControl
import XZPageView


class Example09Test01ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var segmentedControl: XZSegmentedControl!
    @IBOutlet weak var pageView: XZPageView!
    
    let titles = ["业界", "手机", "电脑", "测评", "视频", "AI", "苹果", "鸿蒙", "软件", "数码"];
    var colors  = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in titles {
            let r = CGFloat(arc4random_uniform(256)) / 255.0;
            let g = CGFloat(arc4random_uniform(256)) / 255.0;
            let b = CGFloat(arc4random_uniform(256)) / 255.0;
            let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            colors.append(color)
        }
        
        pageView.isLooped   = false
        pageView.delegate   = self
        pageView.dataSource = self
        
        if segmentedControl.direction == .horizontal {
            segmentedControl.indicatorSize  = CGSize.init(width: 20.0, height: 3.0)
        } else {
            segmentedControl.indicatorSize  = CGSize.init(width: 3.0, height: 20.0)
        }
        segmentedControl.indicatorColor    = .systemRed
        segmentedControl.interitemSpacing  = 10;
        segmentedControl.titleFont         = .systemFont(ofSize: 17.0)
        segmentedControl.selectedTitleFont = .systemFont(ofSize: 20.0, weight: .medium)
        segmentedControl.titles            = self.titles
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }

    @objc func segmentedControlValueChanged(_ sender: XZSegmentedControl) {
        let newIndex = sender.selectedIndex;
        print("XZSegmentedControl.valueChanged: \(newIndex)")
        pageView.setCurrentPage(newIndex, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {
        case "settings":
            if let vc = segue.destination as? Example09SettingsViewController {
                vc.segmentedControl = self.segmentedControl
            }
        default:
            fatalError()
        }
    }
    
}

extension Example09Test01ViewController: XZPageViewDelegate {
    func pageView(_ pageView: XZPageView, willShowView view: UIView, animated: Bool) {
        
    }
    
    func pageView(_ pageView: XZPageView, didShowView view: UIView, animated: Bool) {
        
    }
    
    func pageView(_ pageView: XZPageView, willHideView view: UIView, animated: Bool) {
        
    }
    
    func pageView(_ pageView: XZPageView, didHideView view: UIView, animated: Bool) {
        
    }
    
    
    func pageView(_ pageView: XZPageView, didShowPageAt index: Int) {
        segmentedControl.setSelectedIndex(index, animated: true)
    }
    
    func pageView(_ pageView: XZPageView, didTurnPageIn transition: CGFloat) {
        segmentedControl.updateInteractiveTransition(transition)
    }
}

extension Example09Test01ViewController: XZPageViewDataSource {
    func pageView(_ pageView: XZPageView, shouldReuse reusingView: UIView) -> Bool {
        return true
    }
    
    
    func numberOfPages(in pageView: XZPageView) -> Int {
        return self.titles.count
    }
    
    func pageView(_ pageView: XZPageView, viewForPageAt index: Int, reusing reusingView: UIView?) -> UIView {
        let view = reusingView ?? UIView.init()
        view.backgroundColor = colors[index]
        return view
    }
    
    func pageView(_ pageView: XZPageView, prepareReuseFor reusingView: UIView) -> UIView? {
        return reusingView
    }
    
}


extension Example09Test01ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError()
    }
    
    
}
