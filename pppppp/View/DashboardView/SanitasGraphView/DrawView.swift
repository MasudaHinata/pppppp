import UIKit
import CoreMotion

protocol DrawViewDelegate: AnyObject {
    func buttonSelected(item: UserData)
}
class DrawView: UIView {
    weak var delegate: DrawViewDelegate?

    var paths = [UIBezierPath]()
    var imageButtons = [UIButton]()
    var crownImageButtons = [UIButton]()
    var pointLabels = [UILabel]()
    var friendListItems = [UserData]()
    var friendPositions = [CGPoint]()

    let playerMotionManager = CMMotionManager()
    var vertexPoint: CGPoint = .zero
    var vertexPointTmps: [CGPoint] = Array(repeating: .zero, count: 10)

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startAccelerometer()
    }

    override func draw(_ rect: CGRect) {
        for path in paths {
            path.removeAllPoints()
        }
        paths = []
        if friendPositions.count == 0 {
            friendPositions = []

            //MARK: - x軸の計算
            var largestPoint = CGFloat(friendListItems.first?.point ?? 1)
            if friendListItems.first?.point == 0 {
                largestPoint = CGFloat(friendListItems.first?.point ?? 1) + 0.1
            } else if friendListItems.first?.point != 0 {
                largestPoint = CGFloat(friendListItems.first?.point ?? 1)
            }

            for item in friendListItems {
                var itemPoint = CGFloat(item.point ?? 0)
                if item.point == 0 {
                    itemPoint += 0.1
                }
                //TODO: 大差がついた時に見た目を良くする計算を考える
                let x = itemPoint / largestPoint * bounds.width * 0.8 + bounds.width * 0.1
                let y = CGFloat.random(in: 300 ..< bounds.height * 0.8)
                friendPositions.append(CGPoint(x: x, y: y))
            }
        }

        for (index, item) in friendListItems.enumerated() {
            let alpha = CGFloat(friendListItems.count - index - 1) / CGFloat(friendListItems.count) * 1.8
            let newPosition = friendPositions[index] + (vertexPoint * alpha)
            graph(vertex: newPosition, item: item, index: index)
        }
    }

    func configure(rect: CGRect, friendListItems: [UserData]) {
        self.friendListItems = friendListItems
        self.friendPositions = []
        for button in imageButtons {
            button.removeFromSuperview()
        }
        imageButtons = []
        for label in pointLabels {
            label.removeFromSuperview()
        }
        pointLabels = []
        setNeedsDisplay()
    }

    func graph(vertex: CGPoint, item: UserData, index: Int) {
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

        if index >= pointLabels.count {
            let pointLabel = UILabel()
            pointLabel.font = UIFont(name: "F5.6", size: 12)
            pointLabel.text = "\(item.point ?? 0)pt"
            pointLabel.textAlignment = .center
            self.addSubview(pointLabel)
            pointLabels.append(pointLabel)
        }
        pointLabels[index].frame = CGRect(x: vertex.x - 28, y: vertex.y + 24, width: 56, height: 24)


        if index >= imageButtons.count {
            let imageButton = UIButton()

            imageButton.kf.setImage(with: URL(string: item.iconImageURL), for: .normal)
            imageButton.imageView?.contentMode = .scaleAspectFill
            imageButton.layer.cornerRadius = 28
            imageButton.layer.cornerCurve = .continuous
            imageButton.clipsToBounds = true
            imageButton.addAction(.init { button in self.delegate?.buttonSelected(item: item) }, for: .touchUpInside)
            self.addSubview(imageButton)
            imageButtons.append(imageButton)
        }
        imageButtons[index].frame = CGRect(x: vertex.x - 28, y: vertex.y - 28, width: 56, height: 56)


//        if friendListItems[0].id == item.id  {
//            //TODO: 1位の人に王冠つける
//            print(friendListItems[0].name, "1位")
//
//            let imageButton = UIButton()
//            imageButton.setImage(UIImage(systemName: "crown.fill"), for: .normal)
//            imageButton.imageView?.contentMode = .scaleAspectFill
//            imageButton.layer.cornerRadius = 14
//            imageButton.layer.cornerCurve = .continuous
//            imageButton.clipsToBounds = true
//            imageButton.addAction(.init { button in self.delegate?.buttonSelected(item: item) }, for: .touchUpInside)
//            self.addSubview(imageButton)
//            crownImageButtons.append(imageButton)
//
//            crownImageButtons[0].frame = CGRect(x: vertex.x - 10, y: vertex.y - 42, width: 56, height: 56)
//        }

        paths.append(path)
    }

    //MARK: -　path・アイコン・Labelを動かす
    func startAccelerometer() {
        let handler: CMAccelerometerHandler = {( CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in

            let posX = CGFloat(CMAccelerometerData!.acceleration.x) * 20
            let posY = CGFloat(CMAccelerometerData!.acceleration.y) * -20
            self.vertexPointTmps.removeFirst()
            self.vertexPointTmps.append(CGPoint(x: posX, y: posY))
            self.vertexPoint = self.vertexPointTmps.reduce(CGPoint(x: 0, y: 0), +) / CGFloat(self.vertexPointTmps.count)
            self.setNeedsDisplay()
        }

        playerMotionManager.accelerometerUpdateInterval = 0.008
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
}
