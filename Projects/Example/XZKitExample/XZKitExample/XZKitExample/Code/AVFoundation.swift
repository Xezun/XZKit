//
//  AVFoundation.swift
//  IJKMediaPlayerTest
//
//  Created by mlibai on 2017/6/6.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer.Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "AVPlayerStatus.unknown"
        case .failed:
            return "AVPlayerStatus.failed"
        case .readyToPlay:
            return "AVPlayerStatus.readyToPlay"
        default:
            return "AVPlayer.Status.Unknown"
        }
    }
}

extension AVPlayerItem.Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "AVPlayerItemStatus.unknown"
        case .failed:
            return "AVPlayerItemStatus.failed"
        case .readyToPlay:
            return "AVPlayerItemStatus.readyToPlay"
        default:
            return "AVPlayerItem.Status.Unknown"
        }
    }
}
