import UIKit

protocol DrawViewDelegate: AnyObject {
    func buttonSelected(item: UserData)
}
class DrawView: UIView {
    weak var delegate: DrawViewDelegate?
    
    var paths = [UIBezierPath]()
    var imageButtons = [UIButton]()
    var pointLabels = [UILabel]()
    var friendListItems = [UserData]()
    
    override func draw(_ rect: CGRect) {
        for path in paths {
            path.removeAllPoints()
        }
        for button in imageButtons {
            button.removeFromSuperview()
        }
        for label in pointLabels {
            label.removeFromSuperview()
        }
        
        //MARK: - x軸の計算
        var largestPoint = CGFloat(friendListItems.first?.point ?? 1)
        if friendListItems.first?.point == 0 {
            largestPoint = CGFloat(friendListItems.first?.point ?? 1) + 0.1
        } else if friendListItems.first?.point != 0 {
            largestPoint = CGFloat(friendListItems.first?.point ?? 1)
        }
        
        for item in friendListItems {
            var itemPoint = CGFloat()
            if item.point == 0 {
                itemPoint = CGFloat(Float(item.point!) + 0.1)
            } else {
                itemPoint = CGFloat(Float(item.point!))
            }
            //TODO: 大差がついた時に見た目を良くする計算を考える
            let x = CGFloat(itemPoint / largestPoint * self.bounds.width * 0.8)
            let y = CGFloat(Float.random(in: 300 ..< Float(self.bounds.height * 0.8)))
            graph(vertex: CGPoint(x: x, y: y), item: item)
        }
    }
    func configure(rect: CGRect, friendListItems: [UserData]) {
        self.friendListItems = friendListItems
        setNeedsDisplay()
    }
    func graph(vertex: CGPoint, item: UserData) {
        let delta = min(bounds.height - vertex.y, vertex.y) * 0.4
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
        Asset.Colors.lightBlue25.color.setFill()
        path.fill()
        
        let pointLabel = UILabel()
        pointLabel.frame = CGRect(x: vertex.x - 28, y: vertex.y + 24, width: 56, height: 24)
        pointLabel.font = UIFont(name: "F5.6", size: 12)
        pointLabel.text = "\(item.point ?? 0)pt"
        pointLabel.textAlignment = .center
        self.addSubview(pointLabel)
        pointLabels.append(pointLabel)
        
        let imageButton = UIButton()
        imageButton.frame = CGRect(x: vertex.x - 28, y: vertex.y - 28, width: 56, height: 56)
        imageButton.kf.setImage(with: URL(string: item.iconImageURL), for: .normal)
        imageButton.imageView?.contentMode = .scaleAspectFill
        imageButton.layer.cornerRadius = 28
        imageButton.layer.cornerCurve = .continuous
        imageButton.clipsToBounds = true
        imageButton.addAction(.init { button in self.delegate?.buttonSelected(item: item) }, for: .touchUpInside)
        self.addSubview(imageButton)
        imageButtons.append(imageButton)
        paths.append(path)
    }
}
