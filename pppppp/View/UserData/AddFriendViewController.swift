import UIKit
import Combine

class AddFriendViewController: UIViewController {
    
    var friendId: String!
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var friendLabel: UILabel!
    @IBOutlet var addFriendButton: UIButton! {
        didSet {
            addFriendButton.layer.borderWidth = 4.0
            addFriendButton.layer.borderColor = UIColor.white.cgColor
            addFriendButton.layer.cornerRadius = 12.0
            addFriendButton.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var friendIconView: UIImageView! {
        didSet {
            friendIconView.layer.cornerRadius = 34
            friendIconView.clipsToBounds = true
            friendIconView.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var backgroundView: UIView! {
        didSet {
            backgroundView.layer.cornerRadius = 40
            backgroundView.layer.masksToBounds = true
            backgroundView.layer.cornerCurve = .continuous
        }
    }
    @IBAction func backButton(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        let task = Task {
            do {
                try await friendIconView.kf.setImage(with: FirebaseClient.shared.getFriendData(friendId: friendId!))
                try await friendLabel.text = FirebaseClient.shared.getFriendNameData(friendId: friendId)
            }
            catch {
                
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    //友達を追加する
    @IBAction func addFriend() {
        let task = Task { [weak self] in
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                if friendId == userID {
                    //FIXME: ここでアラート呼びたくない
                    let alertController = UIAlertController(title: "エラー", message: "自分とは友達になれません", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                        self!.showDetailViewController(secondVC, sender: self)
                    })
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                } else {
                    try await FirebaseClient.shared.addFriend(friendId: friendId)
                    //FIXME: ここでアラート呼びたくない
                    let alertController = UIAlertController(title: "友達追加", message: "友達を追加しました", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                        self!.showDetailViewController(secondVC, sender: self)
                    })
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                }
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self!.present(alert, animated: true)
                print("profileViewContro addFriend error:", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}