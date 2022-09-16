import UIKit
import Combine

class AddFriendViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var linkButtonLayout: UIButton! {
        didSet {
            linkButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
        }
    }
    
    @IBOutlet var qrCodeButtonLayout: UIButton! {
        didSet {
            qrCodeButtonLayout.tintColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
//            var configuration = UIButton.Configuration.filled()
//            configuration.title = "QRCode"
//            configuration.baseBackgroundColor = UIColor.init(hex: "A5A1F8", alpha: 0.5)
//            configuration.cornerStyle = .capsule
//            qrCodeButtonLayout.configuration = configuration
        }
    }

    @IBAction func linkButton() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                let shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
                let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
            } catch {
                print("SanitasViewContro showShareSheet:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    let alert = UIAlertController(title: "エラー", message: "インターネット接続を確認してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    @IBAction func qrCodeButton() {
        let storyboard = UIStoryboard(name: "ShareMyDataView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
