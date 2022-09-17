//
//  OnboardingViewController4.swift
//  pppppp
//
//  Created by hinata on 2022/09/17.
//

import UIKit

class OnboardingViewController4: UIViewController {
    
    @IBOutlet var backButtonLayout: UIButton! {
        didSet {
            backButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
        }
    }
    
    @IBOutlet var startButtonLayout: UIButton! {
        didSet {
            startButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
        }
    }
    
    @IBAction func backButton() {
        let storyboard = UIStoryboard(name: "OnboardingView3", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
    
    @IBAction func startButton() {
        let storyboard = UIStoryboard(name: "AddFriendView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
