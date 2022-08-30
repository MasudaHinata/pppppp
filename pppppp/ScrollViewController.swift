//
//  ScrollViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/29.
//

import UIKit

final class ScrollViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var sampleScrollView: UIScrollView! {
        didSet {
            sampleScrollView.delegate = self
            sampleScrollView.isPagingEnabled = true
            sampleScrollView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet private weak var samplePageControl: UIPageControl! {
        didSet {
            samplePageControl.isUserInteractionEnabled = false
        }
    }
    private let scrollHeight: CGFloat = 200.0
    private let imageWidth: CGFloat = UIScreen.main.bounds.width
    
    private lazy var images: [UIImage] = {
        return [UIImage(named: "img_xxx0")!,
                UIImage(named: "img_xxx1")!,
                UIImage(named: "img_xxx2")!]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImages()
    }
    
    private func setupImages() {
        sampleScrollView.contentSize = CGSize(width: imageWidth * CGFloat(images.count),
                                              height: scrollHeight)
        images.enumerated().forEach { index, image in
            let imageView = UIImageView(frame: CGRect(x: imageWidth * CGFloat(index), y: 0, width: imageWidth, height: scrollHeight))
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            sampleScrollView.addSubview(imageView)
        }
        samplePageControl.numberOfPages = images.count
    }
}

// MARK: UIScrollViewDelegate
extension ScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        samplePageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
}
