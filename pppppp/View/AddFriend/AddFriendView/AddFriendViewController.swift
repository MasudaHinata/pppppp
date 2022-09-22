import UIKit
import Combine

class AddFriendViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var addFriendButtonLayout: UIButton! {
        didSet {
            addFriendButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
        }
    }
    
    @IBAction func addFriendButton() {
        let secondVC = StoryboardScene.ShareMyDataView.initialScene.instantiate()
        self.showDetailViewController(secondVC, sender: self)
    }
    
    @IBAction func sceneSetting() {
        let secondVC = StoryboardScene.SettingView.initialScene.instantiate()
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
