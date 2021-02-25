//
//  XZNavigationBarCustomizable.swift
//  XZKit
//
//  Created by Xezun on 2018/1/4.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import UIKit

/// 导航条是否可以自定义。
public protocol XZNavigationBarCustomizable: UIViewController {
    /// 控制器自定义导航条。
    var navigationBarIfLoaded: (UIView & XZNavigationBarCustomizing)? { get }
}

