import UIKit

class OnboardingViewController1: UIViewController {

    @IBOutlet var nextButtonLayout: UIButton! {
        didSet {
            nextButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
        }
    }
    
    @IBAction func nextButton() {
        //TODO: push遷移にする
        let storyboard = UIStoryboard(name: "OnboardingView2", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "initialScreen")
    }
}
