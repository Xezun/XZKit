//
//  Example09SegmentedControlIndicator.swift
//  Example
//
//  Created by 徐臻 on 2024/6/28.
//

import UIKit
import XZSegmentedControl

class Example09SegmentedControlIndicator: XZSegmentedControlIndicator {
    
    override class var supportsInteractiveTransition: Bool {
        return true
    }

    override class func segmentedControl(_ segmentedControl: XZSegmentedControl, layout: XZSegmentedControlLayout, prepareForLayoutAttributes layoutAttributes: XZSegmentedControlIndicatorLayoutAttributes) {
        layoutAttributes.zIndex = -111
        
        let selectedIndex = segmentedControl.selectedIndex;
        guard let frame = layout.layoutAttributesForItem(at: selectedIndex)?.frame else {
            return
        }
        
        if segmentedControl.direction == .horizontal {
            layoutAttributes.frame = frame.insetBy(dx: 0, dy: 5)
        } else {
            layoutAttributes.frame = frame.insetBy(dx: 5, dy: 0)
        }
        
        let interactiveTransition = layoutAttributes.interactiveTransition;
        if interactiveTransition == 0 {
            return
        }
        
        let count = segmentedControl.numberOfSegments;
        
        var newIndex = 0;
        if interactiveTransition > 0 {
            newIndex = Int(min(CGFloat(count - 1), ceil(CGFloat(selectedIndex) + interactiveTransition)));
        } else {
            newIndex = Int(max(0.0, floor(CGFloat(selectedIndex) + interactiveTransition)))
        }
        
        let from = layoutAttributes.frame;
        guard var to = layout.layoutAttributesForItem(at: newIndex)?.frame else {
            return
        }
        
        if segmentedControl.direction == .horizontal {
            to = to.insetBy(dx: 0, dy: 5)
        } else {
            to = to.insetBy(dx: 5, dy: 0)
        }
        
        let percent = abs(interactiveTransition) / ceil(abs(interactiveTransition));
        
        let x = from.minX + (to.minX - from.minX) * percent;
        let y = from.minY + (to.minY - from.minY) * percent;
        let w = from.width + (to.width - from.width) * percent;
        let h = from.height + (to.height - from.height) * percent;
        layoutAttributes.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *) {
            self.backgroundColor = .systemGray5
        } else {
            self.backgroundColor = .darkGray
        }
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
