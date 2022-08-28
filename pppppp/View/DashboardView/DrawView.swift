//
//  DrawView.swift
//  pppppp
//
//  Created by hinata on 2022/08/28.
//

import UIKit

class DrawView: UIView {
    override func draw(_ rect: CGRect) {
        
        graph(vertex: CGPoint(x: CGFloat(Float.random(in: 200 ..< Float(rect.width * 0.8))), y: CGFloat(Float.random(in: 200 ..< Float(rect.height * 0.75)))))
        graph(vertex: CGPoint(x: CGFloat(Float.random(in: 200 ..< Float(rect.width * 0.9))), y: CGFloat(Float.random(in: 200 ..< Float(rect.height * 0.75)))))
        graph(vertex: CGPoint(x: CGFloat(Float.random(in: 200 ..< Float(rect.width * 0.9))), y: CGFloat(Float.random(in: 200 ..< Float(rect.height * 0.75)))))
        graph(vertex: CGPoint(x: CGFloat(Float.random(in: 200 ..< Float(rect.width * 0.9))), y: CGFloat(Float.random(in: 200 ..< Float(rect.height * 0.75)))))
        graph(vertex: CGPoint(x: CGFloat(Float.random(in: 200 ..< Float(rect.width * 0.9))), y: CGFloat(Float.random(in: 200 ..< Float(rect.height * 0.75)))))
        
    }
    func graph(vertex: CGPoint) {
        let delta = min(bounds.height - vertex.y, vertex.y) * 0.55
        let deltaTop = vertex.y - delta
        let deltaBottom = self.bounds.height - vertex.y - delta
        
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 0, y: deltaTop)
        let point3 = CGPoint(x: vertex.x, y: vertex.y - delta)
        let point4 = vertex
        let point5 = CGPoint(x: vertex.x, y: vertex.y + delta)
        let point6 = CGPoint(x: 0, y: self.bounds.height - deltaBottom)
        let point7 = CGPoint(x: 0, y: self.bounds.height)
    
        let path = UIBezierPath()
        path.move(to: point1)
        path.addCurve(to: point4, controlPoint1: point2, controlPoint2: point3)
        path.addCurve(to: point7, controlPoint1: point5, controlPoint2: point6)
        path.close()
        path.lineWidth = 5.0
        UIColor.init(hex: "B8E9FF", alpha: 0.25).setFill()
        path.fill()
    }
}
