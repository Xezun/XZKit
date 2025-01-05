//
//  Example09Test02ViewController.swift
//  Example
//
//  Created by 徐臻 on 2024/7/14.
//

import UIKit
import XZSegmentedControl
import XZMocoa

class Example09Test02ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var segmentedControl: XZSegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let titles = ["业界", "手机", "电脑", "测评", "视频", "AI", "苹果", "鸿蒙", "软件", "数码"];
    var views  = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in titles {
            let view = UIView.init()
            let r = CGFloat(arc4random_uniform(256)) / 255.0;
            let g = CGFloat(arc4random_uniform(256)) / 255.0;
            let b = CGFloat(arc4random_uniform(256)) / 255.0;
            view.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            views.append(view)
            
            scrollView.addSubview(view)
        }
        
        segmentedControl.indicatorSize     = CGSize.init(width: 3.0, height: 20.0)
        segmentedControl.indicatorColor    = .systemRed
        segmentedControl.titles            = self.titles
        segmentedControl.interitemSpacing  = 10;
        segmentedControl.titleFont         = .systemFont(ofSize: 17.0)
        segmentedControl.selectedTitleFont = .boldSystemFont(ofSize: 18.0)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame = scrollView.frame;
        frame.origin = .zero
        for view in views {
            view.frame = frame
            frame.origin.y += frame.height
        }
        scrollView.contentSize = .init(width: 0, height: frame.origin.y)
    }

    @objc func segmentedControlValueChanged(_ sender: XZSegmentedControl) {
        let newIndex = sender.selectedIndex;
        print("XZSegmentedControl.valueChanged: \(newIndex)")
        UIView.animate(withDuration: 0.3, animations: {
            var bounds = self.scrollView.bounds;
            bounds.origin.y = bounds.height * CGFloat(newIndex)
            self.scrollView.bounds = bounds
        });
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset;
        let height      = scrollView.frame.height
        let newY        = contentOffset.y
        let oldY        = height * CGFloat(segmentedControl.selectedIndex)
        let newIndex    = newY > oldY ? Int(floor(newY / height)) : Int(ceil(newY / height))
        let transition  = (newY - CGFloat(newIndex) * height) / height;
        
        print("\(#function) setSelectedIndex: \(newIndex), indicatorTransition: \(transition)")
        segmentedControl.setSelectedIndex(newIndex, animated: false)
        print("\(#function) setTransition: \(transition)")
        segmentedControl.updateInteractiveTransition(transition)
        
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("\(#function) decelerate = \(decelerate)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("\(#function)")
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
