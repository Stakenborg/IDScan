//
//  CornersView.swift
//  scantest
//
//  Created by Brandon Stakenborg on 6/17/19.
//  Copyright © 2019 Brandon Stakenborg. All rights reserved.
//

import UIKit

class CornersView: UIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(10.0)
        context?.setStrokeColor(UIColor.white.cgColor)
        
        context?.move(to: CGPoint(x: 0, y: 40))
        context?.addLine(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: 40, y: 0))
        
        context?.move(to: CGPoint(x: bounds.width, y: 40))
        context?.addLine(to: CGPoint(x: bounds.width, y: 0))
        context?.addLine(to: CGPoint(x: bounds.width-40, y: 0))
        
        context?.move(to: CGPoint(x: 0, y: bounds.height-40))
        context?.addLine(to: CGPoint(x: 0, y: bounds.height))
        context?.addLine(to: CGPoint(x: 40, y: bounds.height))
        
        context?.move(to: CGPoint(x: bounds.width, y: bounds.height-40))
        context?.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        context?.addLine(to: CGPoint(x: bounds.width-40, y: bounds.height))
        
        context?.strokePath()
    }
}
