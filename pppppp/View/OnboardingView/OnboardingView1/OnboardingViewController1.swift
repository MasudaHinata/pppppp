import UIKit

class OnboardingViewController1: UIViewController {
    
    @IBOutlet var messageLabel: UILabel! {
        didSet {
            messageLabel.text = L10n.onboardingView1
        }
    }
    
    @IBOutlet var nextButtonLayout: UIButton! {
        didSet {
            nextButtonLayout.tintColor = Asset.Colors.purple50.color
        }
    }
    
    @IBAction private func nextButton(_ sender: Any) {
        let onboardingView2VC = StoryboardScene.OnboardingView2.initialScene.instantiate()
        let navigationController = UINavigationController(rootViewController: onboardingView2VC)
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
