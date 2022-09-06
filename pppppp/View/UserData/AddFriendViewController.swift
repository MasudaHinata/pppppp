import UIKit
import Combine

class AddFriendViewController: UIViewController, FirebaseAddFriendDelegate {
    
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
    @IBAction func backButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    //友達を追加する
    @IBAction func addFriend() {
        let task = Task { [weak self] in
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                if friendId == userID {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.addFriendDelegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        let task = Task {
            do {
                //FIXME: 並列処理にしたい
                friendIconView.kf.setImage(with: try await FirebaseClient.shared.getFriendData(friendId: friendId!))
                friendLabel.text = try await  FirebaseClient.shared.getFriendNameData(friendId: friendId)
//                async let setFriendIconImage = friendIconView.kf.setImage(with: FirebaseClient.shared.getFriendData(friendId: friendId!))
//                async let setFriendName = FirebaseClient.shared.getFriendNameData(friendId: friendId)
//                let set = try await (setFriendIconImage,setFriendName)
//                friendLabel.text = set.1
            }
            catch {
                
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - Setting Delegate
    func addFriends() {
        let alert = UIAlertController(title: "友達追加", message: "友達を追加しました", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
            self.showDetailViewController(secondVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
