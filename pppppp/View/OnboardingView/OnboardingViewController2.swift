import UIKit

class OnboardingViewController2: UIViewController {
    
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
    
    @IBAction func backButton(_ sender: Any) {
        //TODO: push遷移にする
        let storyBoard = UIStoryboard(name: "OnboardingView1", bundle: nil)
        let viewController = storyBoard.instantiateInitialViewController()
        let navigationController = UINavigationController(rootViewController: viewController!)
        navigationController.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = .push
        transition.subtype = .fromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        present(navigationController, animated: false, completion: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        //TODO: push遷移にする
        let storyBoard = UIStoryboard(name: "OnboardingView3", bundle: nil)
        let viewController = storyBoard.instantiateInitialViewController()
        let navigationController = UINavigationController(rootViewController: viewController!)
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
