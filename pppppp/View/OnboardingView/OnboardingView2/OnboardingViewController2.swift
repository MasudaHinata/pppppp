import UIKit

class OnboardingViewController2: UIViewController {
    
    @IBOutlet var messageLabel: UILabel! {
        didSet {
            messageLabel.text = L10n.onboardingView2
        }
    }
    
    @IBOutlet var messageLabel2: UILabel! {
        didSet {
            messageLabel2.text = L10n.onboardingViewHealthKit
        }
    }
    
    @IBOutlet var backButtonLayout: UIButton! {
        didSet {
            backButtonLayout.tintColor = Asset.Colors.purple50.color
        }
    }
    
    @IBOutlet var nextButtonLayout: UIButton! {
        didSet {
            nextButtonLayout.tintColor = Asset.Colors.purple50.color
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        let secondVC = StoryboardScene.OnboardingView1.initialScene.instantiate()
        let navigationController = UINavigationController(rootViewController: secondVC)
        navigationController.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = .push
        transition.subtype = .fromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        present(navigationController, animated: false, completion: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let secondVC = StoryboardScene.OnboardingView3.initialScene.instantiate()
        let navigationController = UINavigationController(rootViewController: secondVC)
        navigationController.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = .push
        transition.subtype = .fromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        present(navigationController, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
