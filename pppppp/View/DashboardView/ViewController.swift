import Combine
import UIKit
import SwiftUI

class ViewController: UIViewController, FirebaseEmailVarifyDelegate ,FirebasePutPointDelegate, DrawViewDelegate, FireStoreCheckNameDelegate {
    
    var cancellables = Set<AnyCancellable>()
    var friendIdList = [String]()
    var friendDataList = [UserData]()
    let UD = UserDefaults.standard
    let calendar = Calendar.current
    var ActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var noFriendView: UIView!
    @IBOutlet var noFriendLabel: UILabel!
    @IBOutlet var noFriendButtonLayout: UIButton!
    @IBOutlet var mountainView: DrawView!
    
    @IBAction func noFriendButton() {
        showShareSheet()
    }
    
    @IBAction func sendCollectionView() {
        let storyboard = UIStoryboard(name: "DashboardView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "DashboardViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.emailVerifyDelegate = self
        FirebaseClient.shared.putPointDelegate = self
        FirebaseClient.shared.notChangeDelegate = self
        NotificationManager.setCalendarNotification(title: "自己評価をしてポイントを獲得しましょう", body: "19時になりました")
        
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.style = .large
        ActivityIndicator.hidesWhenStopped = true
        self.view.addSubview(ActivityIndicator)
        mountainView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ActivityIndicator.startAnimating()
        var judge = Bool()
        let now = calendar.component(.hour, from: Date())
        if now >= 19 {
            judge = true
        }
        else {
            judge = false
        }
        if judge == true {
            judge = false
            var judgge = Bool()
            if UD.object(forKey: "selfCheckJudge") != nil {
                let past_day = UD.object(forKey: "selfCheckJudge") as! Date
                let noww = calendar.component(.day, from: Date())
                let past = calendar.component(.day, from: past_day)
                if noww != past {
                    judgge = true
                } else {
                    judgge = false
                }
            } else {
                judgge = true
                UD.set(Date(), forKey: "selfCheckJudge")
            }
            if judgge {
                judgge = false
                UD.set(Date(), forKey: "selfCheckJudge")
                let storyboard = UIStoryboard(name: "SelfCheckView", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "SelfCheckViewController")
                secondVC.modalPresentationStyle = .overFullScreen
                secondVC.modalTransitionStyle = .crossDissolve
                self.present(secondVC, animated: true)
            }
        }
        
        mountainView.configure(rect: self.view.bounds, friendListItems: friendDataList)
        if friendDataList.count == 1 {
            print("friendなし")
            noFriendView.backgroundColor = UIColor.init(hex: "85A0C5")
            noFriendView.layer.cornerRadius = 20
            noFriendView.layer.cornerCurve = .continuous
        }
        let task = Task { [weak self] in
            do {
                try await FirebaseClient.shared.userAuthCheck()
                try await Scorering.shared.createStepPoint()
                self!.friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                mountainView.configure(rect: self!.view.bounds, friendListItems: self!.friendDataList)
                if friendDataList.count == 1 {
                    print("friendなし")
                    noFriendView.backgroundColor = UIColor.init(hex: "85A0C5")
                    noFriendView.layer.cornerRadius = 20
                    noFriendView.layer.cornerCurve = .continuous
                    ActivityIndicator.stopAnimating()
                }
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                alert.addAction(ok)
                self!.present(alert, animated: true, completion: nil)
                print("ViewContro ViewAppear error:",error.localizedDescription)
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
    
    func showShareSheet() {
        let task = Task {
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                let shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
                let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
            } catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.viewDidLoad()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                print("FriendListViewContro showShareSheet:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - Setting Delegate
    func emailVerifyRequiredAlert() {
        let alert = UIAlertController(title: "仮登録が完了していません", message: "メールを確認してください", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "CreateAccountViewController")
            self.showDetailViewController(secondVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func putPointForFirestore(point: Int) {
        let alert = UIAlertController(title: "ポイントを獲得しました", message: "あなたのポイントは\(point)pt", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func notGetPoint() {
        let alert = UIAlertController(title: "今日の獲得ポイントは0ptです", message: "がんばりましょう", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func buttonSelected(item: UserData) {
        let storyboard = UIStoryboard(name: "UserDataView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "UserDataViewController") as UserDataViewController
        secondVC.userDataItem = item
        self.showDetailViewController(secondVC, sender: self)
    }
    func notChangeName() {
        let storyboard = UIStoryboard(name: "SetNameView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "SetNameViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
}
