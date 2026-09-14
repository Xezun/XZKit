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
    
    func contentStatus(_ contentStatus: XZContentStatus, performActionForInteraction: Any) {
        switch contentStatus {
        case .loading:
            self.contentStatus = .error
        case .error:
            self.contentStatus = .empty
        case .empty:
            self.contentStatus = .unavailable
        case .unavailable:
            self.contentStatus = .unreachable
        case .unreachable:
            self.contentStatus = nil
        default:
            self.contentStatus = .loading;
        }
    }
    
    @IBAction func refreshButtonAction(_ sender: UIBarButtonItem) {
        self.contentStatus = .view(.loading, view: Example12ContentStatusView(delegate: self), isInteractive: false)
    }
    
    func loadingView(_ loadingView: Example12ContentStatusView, didSelectLoadResult contentStatus: XZContentStatus?) {
        self.contentStatus = contentStatus
    }
    
}

