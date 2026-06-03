//
//  Example12ViewController.swift
//  Example
//
//  Created by Xezun on 2025/1/5.
//

import UIKit
import XZKit

@mocoa
class Example12ViewController: UIViewController, XZContentStatusRepresentable, Example12ContentStatusViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentStatus = .loading
    }
    
    func shouldPerformUpdates(for contentStatus: XZContentStatus) -> XZContentStatus? {
        switch contentStatus {
        case .loading:
            return .error
        case .error:
            return .empty
        case .empty:
            return .unavailable
        case .unavailable:
            return .unreachable
        case .unreachable:
            return nil
        default:
            return .loading;
        }
    }
    
    @IBAction func refreshButtonAction(_ sender: UIBarButtonItem) {
        self.contentStatus = .view(.loading, view: Example12ContentStatusView(delegate: self), isInteractive: false)
    }
    
    func loadingView(_ loadingView: Example12ContentStatusView, didSelectLoadResult contentStatus: XZContentStatus?) {
        self.contentStatus = contentStatus
    }
    
}

