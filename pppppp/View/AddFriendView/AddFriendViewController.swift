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
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                if friendId == userID {
                    let alertController = UIAlertController(title: "エラー", message: "自分とは友達になれません", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                        self.showDetailViewController(secondVC, sender: self)
                    })
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                } else {
                    try await FirebaseClient.shared.addFriend(friendId: friendId)
                }
            }
            catch {
                print("AddFriendViewContro addFriend error:", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    let alert = UIAlertController(title: "エラー", message: "インターネット接続を確認してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.viewDidAppear(true)
                    }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.addFriendDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let task = Task {
            do {
                friendLabel.text = try await  FirebaseClient.shared.getFriendNameData(friendId: friendId)
                friendIconView.kf.setImage(with: try await FirebaseClient.shared.getFriendIconData(friendId: friendId!))
            }
            catch {
                print("AddFriendView ViewAppear error:", error.localizedDescription)
                if error.localizedDescription == "The operation couldn’t be completed. (pppppp.FirebaseClientFirestoreError error 0.)" {
                    let alert = UIAlertController(title: "エラー", message: "アカウントが存在しません", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                        self.showDetailViewController(secondVC, sender: self)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - Setting Delegate
    func addFriends() {
        let alert = UIAlertController(title: "完了", message: "友達を追加しました", preferredStyle: .alert)
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
    
    func friendNotFound() {
        let alert = UIAlertController(title: "エラー", message: "アカウントが存在しません", preferredStyle: .alert)
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
