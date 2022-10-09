import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTab()
    }
    
    func setupTab() {
        let sanitasVC = StoryboardScene.SanitasView.initialScene.instantiate()
        sanitasVC.tabBarItem = UITabBarItem(title: "Home", image: .none, tag: 0)

        let timelineVC = StoryboardScene.TimeLineView.initialScene.instantiate()
        timelineVC.tabBarItem = UITabBarItem(title: "Timeline", image: .none, tag: 1)

        let profileVC = ProfileViewController(viewModel: .init())
        profileVC.tabBarItem = UITabBarItem(title: "Me", image: .none, tag: 2)

        viewControllers = [sanitasVC, timelineVC, profileVC]
    }
}
