import UIKit

class OnboardingViewController3: UIViewController {
    
    @IBOutlet var backButtonLayout: UIButton! {
        didSet {
            backButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
        }
    }
    
    @IBOutlet var nextButtonLayout: UIButton! {
        didSet {
            nextButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
        }
    }
    
    @IBAction func backButton() {
        let storyboard = UIStoryboard(name: "OnboardingView2", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
    
    @IBAction func nextButton() {
        let storyboard = UIStoryboard(name: "AddFriendView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
