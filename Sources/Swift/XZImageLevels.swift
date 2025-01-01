//
//  UIImage+XZKit.swift
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

import Foundation

extension XZImage.Levels {
    
    public init(shadows: CGFloat, midtones: CGFloat, highlights: CGFloat) {
        let input = Input(shadows, midtones, highlights);
        let output = Output(0.0, 1.0)
        self.init(input: input, output: output, channels: .RGB)
    }
    
    public init(_ shadows: CGFloat, _ midtones: CGFloat, _ highlights: CGFloat) {
        self.init(shadows: shadows, midtones: midtones, highlights: highlights)
    }
    
}


extension XZImage.Levels.Input {
    
    public init(_ shadows: CGFloat, _ highlights: CGFloat) {
        self.init(shadows: shadows, midtones: 1.0, highlights: highlights);
    }
    
    public init(_ shadows: CGFloat, _ midtones: CGFloat, _ highlights: CGFloat) {
        self.init(shadows: shadows, midtones: midtones, highlights: highlights);
    }
    
}


extension XZImage.Levels.Output {
    
    public init(_ shadows: CGFloat, _ highlights: CGFloat) {
        self.init(shadows: shadows, highlights: highlights);
    }
    
}
