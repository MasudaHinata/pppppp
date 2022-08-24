import UIKit
import Combine

class ProfileViewController: UIViewController {
    
    var friendId: String!
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var friendLabel: UILabel!
    @IBOutlet var addFriendButton: UIButton!
    @IBOutlet var friendIconView: UIImageView!
    
    @IBAction func backButton(){
        self.performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendIconView.layer.cornerRadius = 88
        friendIconView.clipsToBounds = true
        friendIconView.layer.cornerCurve = .continuous
        
        addFriendButton.layer.borderWidth = 4.0
        addFriendButton.layer.borderColor = UIColor.white.cgColor
        addFriendButton.layer.cornerRadius = 12.0
        addFriendButton.layer.cornerCurve = .continuous
    }
    override func viewDidAppear(_ animated: Bool) {
        let task = Task { [weak self] in
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
                try await FirebaseClient.shared.addFriend(friendId: friendId)
                let alertController = UIAlertController(title: "友達追加", message: "友達を追加しました", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                    self?.performSegue(withIdentifier: "toViewController", sender: nil)
                })
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
            catch {
                print("profileViewContro addFriend: error")
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}
