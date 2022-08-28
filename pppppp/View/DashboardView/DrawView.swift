//
//  DrawView.swift
//  pppppp
//
//  Created by hinata on 2022/08/28.
//

import Foundation
import UIKit

class DrawView: UIView {
    
    var paths = [UIBezierPath]()
    var imageViews = [UIImageView]()
    var friendListItems = [FriendListItem]()
    
    override func draw(_ rect: CGRect) {
        for path in paths {
            path.removeAllPoints()
        }
        for imageView in imageViews {
            imageView.removeFromSuperview()
        }
        for item in friendListItems {
            graph(vertex: CGPoint(x: CGFloat(Float.random(in: 200 ..< Float(self.bounds.width * 0.9))), y: CGFloat(Float.random(in: 350 ..< Float(self.bounds.height * 0.7)))), imageURL: item.IconImageURL)
        }
    }

    func configure(rect: CGRect, friendListItems: [FriendListItem]) {
        self.friendListItems = friendListItems
        setNeedsDisplay()
    }
    
    func graph(vertex: CGPoint, imageURL: String) {
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
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: vertex.x - 28, y: vertex.y - 28, width: 56, height: 56)
        imageView.kf.setImage(with: URL(string: imageURL))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 24
        imageView.layer.cornerCurve = .continuous
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        paths.append(path)
        imageViews.append(imageView)
    }
}
