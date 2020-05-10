//
//  UIDevice.swift
//  XZKit
//
//  Created by mlibai on 2017/4/25.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

/// 设备
public enum Device: CustomStringConvertible {
    
    /// iOS 设备。
    case iOS
    
    case iPhone;
    
    case iPhone3G;
    case iPhone3GS;
    
    case iPhone4;
    case iPhone4s;
    
    case iPhone5;
    case iPhone5s;
    case iPhone5c;
    
    case iPhone6;
    case iPhone6Plus;
    case iPhone6s;
    case iPhone6sPlus;
    
    case iPhoneSE;
    
    case iPhone7;
    case iPhone7Plus;
    
    case iPhone8;
    case iPhone8Plus;
    
    case iPhoneX;
    
    case iPhoneXr
    case iPhoneXs
    case iPhoneXsMax
    
    // iPod
    
    
    /// 竖屏方向上大小。
    public var screenSize: CGSize {
        switch self {
        case .iOS:          fallthrough
        case .iPhone:       fallthrough;
        case .iPhone3G:     fallthrough;
        case .iPhone3GS:    fallthrough;
        case .iPhone4:      fallthrough;
        case .iPhone4s:     return CGSize(width: 320, height: 480);

        case .iPhone5:      fallthrough;
        case .iPhone5c:     fallthrough;
        case .iPhone5s:     fallthrough;
        case .iPhoneSE:     return CGSize(width: 320, height: 568);
            
        case .iPhone6:      fallthrough;
        case .iPhone6s:     fallthrough;
        case .iPhone7:      fallthrough;
        case .iPhone8:      return CGSize(width: 375, height: 667);
            
        case .iPhone6Plus:  fallthrough;
        case .iPhone6sPlus: fallthrough;
        case .iPhone7Plus:  fallthrough;
        case .iPhone8Plus:  return CGSize(width: 414, height: 736);
            
        case .iPhoneX:      fallthrough
        case .iPhoneXs:     return CGSize(width: 375, height: 812);
            
        case .iPhoneXr:     fallthrough
        case .iPhoneXsMax:  return CGSize(width: 414, height: 896)
        }
    }
    
    public static var current: Device {
        switch UIDevice.current.model {
        case "iPhone1,1": return .iPhone;
        case "iPhone1,2": return .iPhone3G;
        case "iPhone2,1": return .iPhone3GS;
        case "iPhone3,1": return .iPhone4;      // (GSM)
        case "iPhone3,3": return .iPhone4;      // (CDMA)
        case "iPhone4,1": return .iPhone4s;
        case "iPhone5,1": return .iPhone5;      // (A1428)
        case "iPhone5,2": return .iPhone5;      // (A1429)
        case "iPhone5,3": return .iPhone5c;     // (A1456/A1532)
        case "iPhone5,4": return .iPhone5c;     // (A1507/A1516/A1529)
        case "iPhone6,1": return .iPhone5s;     // (A1433/A1453)
        case "iPhone6,2": return .iPhone5s;     // (A1457/A1518/A1530)
        case "iPhone7,1": return .iPhone6Plus;
        case "iPhone7,2": return .iPhone6;
        case "iPhone8,1": return .iPhone6s;
        case "iPhone8,2": return .iPhone6sPlus;
        case "iPhone8,4": return .iPhoneSE;
        case "iPhone9,1": return .iPhone7;      // (A1660/A1779/A1780)
        case "iPhone9,2": return .iPhone7Plus;  // (A1661/A1785/A1786)
        case "iPhone9,3": return .iPhone7;      // (A1778)
        case "iPhone9,4": return .iPhone7Plus;  // (A1784)
        case "iPhone10,1": return .iPhone8;     // (A1863/A1906)
        case "iPhone10,2": return .iPhone8Plus; // (A1864/A1898)
        case "iPhone10,3": return .iPhoneX;     // (A1865/A1902)
        case "iPhone10,4": return .iPhone8;     // (A1905)
        case "iPhone10,5": return .iPhone8Plus; // (A1897)
        case "iPhone10,6": return .iPhoneX;     // (A1901)
        case "iPhone11,2": return .iPhoneXs;
        case "iPhone11,4": return .iPhoneXsMax;
        case "iPhone11,6": return .iPhoneXsMax;
        case "iPhone11,8": return .iPhoneXr;
        default: return .iOS;
        }
    }
    
    public var description: String {
        switch UIDevice.current.model {
        // iPhone
        case "iPhone1,1": return "iPhone"
        case "iPhone1,2": return "iPhone 3G"
        case "iPhone2,1": return "iPhone 3GS"
        case "iPhone3,1": return "iPhone 4 (GSM)"
        case "iPhone3,3": return "iPhone 4 (CDMA)"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1": return "iPhone 5 (A1428)"
        case "iPhone5,2": return "iPhone 5 (A1429)"
        case "iPhone5,3": return "iPhone 5c (A1456/A1532)"
        case "iPhone5,4": return "iPhone 5c (A1507/A1516/A1529)"
        case "iPhone6,1": return "iPhone 5s (A1433/A1453)"
        case "iPhone6,2": return "iPhone 5s (A1457/A1518/A1530)"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone9,1": return "iPhone 7 (A1660/A1779/A1780)"
        case "iPhone9,2": return "iPhone 7 Plus (A1661/A1785/A1786)"
        case "iPhone9,3": return "iPhone 7 (A1778)"
        case "iPhone9,4": return "iPhone 7 Plus (A1784)"
        case "iPhone10,1": return "iPhone 8 (A1863/A1906)"
        case "iPhone10,2": return "iPhone 8 Plus (A1864/A1898)"
        case "iPhone10,3": return "iPhone X (A1865/A1902)"
        case "iPhone10,4": return "iPhone 8 (A1905)"
        case "iPhone10,5": return "iPhone 8 Plus (A1897)"
        case "iPhone10,6": return "iPhone X (A1901)"
        case "iPhone11,2": return "iPhone Xs"
        case "iPhone11,4": return "iPhone Xs Max"
        case "iPhone11,6": return "iPhone Xs Max"
        case "iPhone11,8": return "iPhone Xr"
        // iPad
        case "iPad1,1": return "iPad"
        case "iPad1,2": return "iPad 3G"
        case "iPad2,1": return "iPad 2 (Wi-Fi)"
        case "iPad2,2": return "iPad 2 (GSM)"
        case "iPad2,3": return "iPad 2 (CDMA)"
        case "iPad2,4": return "iPad 2 (Wi-Fi, revised)"
        case "iPad2,5": return "iPad mini (Wi-Fi)"
        case "iPad2,6": return "iPad mini (A1454)"
        case "iPad2,7": return "iPad mini (A1455)"
        case "iPad3,1": return "iPad (3rd gen, Wi-Fi)"
        case "iPad3,2": return "iPad (3rd gen, LTE Verizon)"
        case "iPad3,3": return "iPad (3rd gen, LTE AT&T)"
        case "iPad3,4": return "iPad (4th gen, Wi-Fi)"
        case "iPad3,5": return "iPad (4th gen, A1459)"
        case "iPad3,6": return "iPad (4th gen, A1460)"
        case "iPad4,1": return "iPad Air (Wi-Fi)"
        case "iPad4,2": return "iPad Air (LTE)"
        case "iPad4,3": return "iPad Air (Rev)"
        case "iPad4,4": return "iPad mini 2 (Wi-Fi)"
        case "iPad4,5": return "iPad mini 2 (LTE)"
        case "iPad4,6": return "iPad mini 2 (Rev)"
        case "iPad4,7": return "iPad mini 3 (Wi-Fi)"
        case "iPad4,8": return "iPad mini 3 (A1600)"
        case "iPad4,9": return "iPad mini 3 (A1601)"
        case "iPad5,1": return "iPad mini 4 (Wi-Fi)"
        case "iPad5,2": return "iPad mini 4 (LTE)"
        case "iPad5,3": return "iPad Air 2 (Wi-Fi)"
        case "iPad5,4": return "iPad Air 2 (LTE)"
        case "iPad6,3": return "iPad Pro 9.7"
        case "iPad6,4": return "iPad Pro 9.7"
        case "iPad6,7": return "iPad Pro 12.9 (Wi-Fi)"
        case "iPad6,8": return "iPad Pro 12.9 (LTE)"
        case "iPad6,11": return "iPad 5"
        case "iPad6,12": return "iPad 5"
        case "iPad7,1": return "iPad Pro 12.9 inch 2nd gen"
        case "iPad7,2": return "iPad Pro 12.9 inch 2nd gen"
        case "iPad7,3": return "iPad Pro 10.5 inch"
        case "iPad7,4": return "iPad Pro 10.5 inch"
        // iPod
        case "iPod1,1": return "iPod touch"
        case "iPod2,1": return "iPod touch (2nd gen)"
        case "iPod3,1": return "iPod touch (3rd gen)"
        case "iPod4,1": return "iPod touch (4th gen)"
        case "iPod5,1": return "iPod touch (5th gen)"
        case "iPod7,1": return "iPod touch (6th gen)"
            
        case "i386", "x86_64", "iPhone": return "Simulator"
        default: return "iOS Device"
        }
    }
    
}
