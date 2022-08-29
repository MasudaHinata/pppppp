////
////  ScroooolleViewController.swift
////  pppppp
////
////  Created by hinata on 2022/08/29.
////
//
//import UIKit
//
//class ScroooolleViewController: UIViewController, UIScrollViewDelegate {
//
//    @IBOutlet var scrollView: UIScrollView!
//    private var pageControl: UIPageControl!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // scrollViewの画面表示サイズを指定
//        scrollView = UIScrollView(frame: CGRect(x: 0, y: 200, width: self.view.frame.size.width, height: 200))
//        // scrollViewのサイズを指定（幅は1メニューに表示するViewの幅×ページ数）
//        scrollView.contentSize = CGSize(width: self.view.frame.size.width*3, height: 200)
//        // scrollViewのデリゲートになる
//        scrollView.delegate = self
//        // メニュー単位のスクロールを可能にする
//        scrollView.isPagingEnabled = true
//        // 水平方向のスクロールインジケータを非表示にする
//        scrollView.showsHorizontalScrollIndicator = false
//        self.view.addSubview(scrollView)
//
//        // scrollView上にUIImageViewをページ分追加する(今回は2ページ分)
//        let imageView1 = createImageView(x: 0, y: 0, width: self.view.frame.size.width, height: 200, image: "image1")
//        scrollView.addSubview(imageView1)
//        imageView1.kf.setImage(with: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/healthcare-58d8a.appspot.com/o/posts%2F1661610611.535855.jpg?alt=media&token=59817508-e9c9-4931-ae2e-c01cd2f5af1f"))
//
//        let imageView2 = createImageView(x: self.view.frame.size.width, y: 0, width: self.view.frame.size.width, height: 200, image: "image2")
//        scrollView.addSubview(imageView2)
//
//        // pageControlの表示位置とサイズの設定
//        pageControl = UIPageControl(frame: CGRect(x: self.view.frame.size.width, y: 0 * 0.95, width: 400, height: 400))
//        // pageControlのページ数を設定
//        pageControl.numberOfPages = 2
//        // pageControlのドットの色
//        pageControl.pageIndicatorTintColor = UIColor.lightGray
//        // pageControlの現在のページのドットの色
//        pageControl.currentPageIndicatorTintColor = UIColor.black
//        self.view.addSubview(pageControl)
//    }
//    // UIImageViewを生成
//    func createImageView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, image: String) -> UIImageView {
//        let imageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
//        let image = UIImage(named:  image)
//        imageView.image = image
//        imageView.backgroundColor = .white
//        return imageView
//    }
//}
//class DrawView: UIView {
//
//    var paths = [UIBezierPath]()
//    var imageViews = [UIImageView]()
//    var friendListItems = [FriendListItem]()
//
//    override func draw(_ rect: CGRect) {
//        for path in paths {
//            path.removeAllPoints()
//        }
//        for imageView in imageViews {
//            imageView.removeFromSuperview()
//        }
//        let largestPoint = CGFloat(friendListItems.first?.point ?? 0)
//        for item in friendListItems {
//            let x = CGFloat(sqrt(CGFloat(item.point!) / largestPoint) * self.bounds.width * 0.8)
//            graph(vertex: CGPoint(x: x, y:CGFloat(Float.random(in: 350 ..< Float(self.bounds.height * 0.7)))), imageURL: item.IconImageURL)
//        }
//    }
//
//    func configure(rect: CGRect, friendListItems: [FriendListItem]) {
//        self.friendListItems = friendListItems
//        setNeedsDisplay()
//    }
//
//    func graph(vertex: CGPoint, imageURL: String) {
//        let delta = min(bounds.height - vertex.y, vertex.y) * 0.55
//        let deltaTop = vertex.y - delta
//        let deltaBottom = self.bounds.height - vertex.y - delta
//
//        let point1 = CGPoint(x: 0, y: 0)
//        let point2 = CGPoint(x: 0, y: deltaTop)
//        let point3 = CGPoint(x: vertex.x, y: vertex.y - delta)
//        let point4 = vertex
//        let point5 = CGPoint(x: vertex.x, y: vertex.y + delta)
//        let point6 = CGPoint(x: 0, y: self.bounds.height - deltaBottom)
//        let point7 = CGPoint(x: 0, y: self.bounds.height)
//
//        let path = UIBezierPath()
//        path.move(to: point1)
//        path.addCurve(to: point4, controlPoint1: point2, controlPoint2: point3)
//        path.addCurve(to: point7, controlPoint1: point5, controlPoint2: point6)
//        path.close()
//        path.lineWidth = 5.0
//        UIColor.init(hex: "B8E9FF", alpha: 0.25).setFill()
//        path.fill()
//
//        let imageView = UIImageView()
//        imageView.frame = CGRect(x: vertex.x - 28, y: vertex.y - 28, width: 56, height: 56)
//        imageView.kf.setImage(with: URL(string: imageURL))
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 24
//        imageView.layer.cornerCurve = .continuous
//        imageView.clipsToBounds = true
//        self.addSubview(imageView)
//        paths.append(path)
//        imageViews.append(imageView)
//    }
//}
//
