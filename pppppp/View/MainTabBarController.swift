import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTab()
    }
    
    func setupTab() {
        let sanitasVC = StoryboardScene.SanitasView.initialScene.instantiate()
        sanitasVC.tabBarItem = UITabBarItem(title: "Home", image: .init(systemName: "house"), tag: 0)

        let timelineVC = StoryboardScene.TimeLineView.initialScene.instantiate()
        timelineVC.tabBarItem = UITabBarItem(title: "Timeline", image: .init(systemName: "message"), tag: 1)

        let profileVC = ProfileHostingController(viewModel: .init())
        profileVC.tabBarItem = UITabBarItem(title: "Me", image: .init(systemName: "person"), tag: 2)

        viewControllers = [sanitasVC, timelineVC, profileVC]
    }
}
