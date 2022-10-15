import UIKit
import Combine

class FriendProfileViewController: UIViewController, SentFriendRequestDelegate {
    
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
            friendIconView.layer.cornerRadius = 40
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
//        self.dismiss(animated: true, completion: nil)
        let mainVC = StoryboardScene.Main.initialScene.instantiate()
        self.showDetailViewController(mainVC, sender: self)
    }
    
    //MARK: - 友達リクエストを送る
    @IBAction func addFriend() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                if friendId == userID {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "自分とは友達になれません") { _ in
                        let mainVC = StoryboardScene.Main.initialScene.instantiate()
                        self.showDetailViewController(mainVC, sender: self)
                        //                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    try await FirebaseClient.shared.sendFriendRequest(friendId: friendId)
                }
            }
            catch {
                print("FriendProfileViewContro addFriend error:", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                        self.viewDidAppear(true)
                    }
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.sentFriendRequestDelegate = self

        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                var friendData = [UserData]()
                friendData = try await FirebaseClient.shared.getUserDataFromId(userId: friendId)
                friendLabel.text = friendData.last?.name
                friendIconView.kf.setImage(with: URL(string: friendData.last!.iconImageURL))
            }
            catch {
                print("FriendProfileViewContro ViewAppear error:", error.localizedDescription)
                if error.localizedDescription == "The operation couldn’t be completed. (pppppp.FirebaseClientFirestoreError error 0.)" {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "アカウントが存在しません") { _ in
                        //                        self.dismiss(animated: true, completion: nil)
                        let mainVC = StoryboardScene.Main.initialScene.instantiate()
                        self.showDetailViewController(mainVC, sender: self)
                    }
                } else if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }

    //MARK: - Setting Delegate
    func sendRequest() {
        let alert = UIAlertController(title: "完了", message: "友達リクエストを送信しました", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            //            self.dismiss(animated: true, completion: nil)
            let mainVC = StoryboardScene.Main.initialScene.instantiate()
            self.showDetailViewController(mainVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func friendNotFound() {
        let alert = UIAlertController(title: "エラー", message: "アカウントが存在しません", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let mainVC = StoryboardScene.Main.initialScene.instantiate()
            self.showDetailViewController(mainVC, sender: self)
            //            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
