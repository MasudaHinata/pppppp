import UIKit
import Combine

class AddFriendViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()

    @IBOutlet var qrCodeButtonLayout: UIButton! {
        didSet {
            qrCodeButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
        }
    }

    @IBAction func qrCodeButton() {
        let storyboard = UIStoryboard(name: "ShareMyDataView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
    
    @IBAction func sceneSetting() {
        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
