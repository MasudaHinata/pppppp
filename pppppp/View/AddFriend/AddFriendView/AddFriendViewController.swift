import UIKit
import Combine

class AddFriendViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var addFriendButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Add Friend!"
            configuration.baseBackgroundColor = Asset.Colors.subColor.color
            configuration.cornerStyle = .capsule
            addFriendButtonLayout.configuration = configuration
        }
    }
    
    @IBAction func addFriendButton() {
        let shareMyDataVC = StoryboardScene.ShareMyDataView.initialScene.instantiate()
        self.showDetailViewController(shareMyDataVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
