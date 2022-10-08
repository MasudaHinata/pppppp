import UIKit
import CoreMotion

class PersonalPathView: UIView {
    
    weak var delegate: DrawViewDelegate?
    
    var playerMotionManager: CMMotionManager!
    var paths = [UIBezierPath]()
    var imageButtons = [UIButton]()
    var pointLabels = [UILabel]()
    var friendListItems = UserData.self
    
    func configure(rect: CGRect, friendListItems: UserData) {
//        self.friendListItems = friendListItems
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
//        startAccelerometer(vertex: , item: )
        
    }
    
    
    func graph(vertex: CGPoint, item: UserData) {
        let delta = min(self.bounds.height - vertex.y, vertex.y) * 0.4
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
    
    func startAccelerometer(vertex: CGPoint, item: UserData) {
        let handler: CMAccelerometerHandler = {( CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            var vertexPoint = vertex
            let posX = self.frame.width / 2 + (CGFloat(CMAccelerometerData!.acceleration.x) * 20)
            let posY = self.frame.height / 2 - (CGFloat(CMAccelerometerData!.acceleration.y) * 20)
            vertexPoint = CGPoint(x: posX, y: posY)
            
            self.graph(vertex: vertexPoint, item: item)
        }
        
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
}

