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
    
    @IBOutlet var stepsLabel: UILabel!
    @IBOutlet var noFriendView: UIView!
    @IBOutlet var noFriendLabel: UILabel!
    @IBOutlet var noFriendButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = .clear
            configuration.showsActivityIndicator = false
            noFriendButtonLayout.configuration = configuration
            noFriendButtonLayout.titleColor(for: .disabled)
        }
    }
    @IBOutlet var mountainView: DrawView!
    
    @IBAction func noFriendButton() {
        showShareSheet()
    }
    
    @IBAction func sendCollectionView() {
        let storyboard = UIStoryboard(name: "DashboardView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "DashboardViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    @IBAction func reloadButton() {
        let task = Task { [weak self] in
            do {
                ActivityIndicator.startAnimating()
                stepsLabel.text = "Today  \(Int(try await Scorering.shared.getTodaySteps())) steps"
                self!.friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                mountainView.configure(rect: self!.view.bounds, friendListItems: self!.friendDataList)
                ActivityIndicator.stopAnimating()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self!.viewDidAppear(true)
                }
                alert.addAction(ok)
                self!.present(alert, animated: true, completion: nil)
                print("ViewContro reloadButton error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
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
        mountainView.configure(rect: self.view.bounds, friendListItems: friendDataList)
        if friendDataList.count == 1 {
            noFriendView.backgroundColor = UIColor.init(hex: "443FA3")
            noFriendView.layer.cornerRadius = 20
            noFriendView.layer.cornerCurve = .continuous
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Add Friend"
            configuration.baseBackgroundColor = UIColor.init(hex: "B8E9FF", alpha: 0.4)
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
            noFriendButtonLayout.layer.borderWidth = 4.0
            noFriendButtonLayout.layer.borderColor = UIColor.white.cgColor
            noFriendButtonLayout.layer.cornerRadius = 12.0
            noFriendButtonLayout.layer.cornerCurve = .continuous
            noFriendLabel.textColor = UIColor.white
            noFriendButtonLayout.configuration = configuration
        }
        let task = Task { [weak self] in
            do {
                stepsLabel.text = "Today  \(Int(try await Scorering.shared.getTodaySteps())) steps"
                try await FirebaseClient.shared.userAuthCheck()
                let now = calendar.component(.hour, from: Date())
                if now >= 19 {
                    let selfCheckJudge = try await FirebaseClient.shared.checkSelfCheck()
                    if selfCheckJudge == true {
                        let storyboard = UIStoryboard(name: "SelfCheckView", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "SelfCheckViewController")
                        secondVC.modalPresentationStyle = .overFullScreen
                        secondVC.modalTransitionStyle = .crossDissolve
                        self!.present(secondVC, animated: true)
                    }
                }
                self!.friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                mountainView.configure(rect: self!.view.bounds, friendListItems: self!.friendDataList)
                if friendDataList.count == 1 {
                    noFriendView.backgroundColor = UIColor.init(hex: "443FA3")
                    noFriendView.layer.cornerRadius = 20
                    noFriendView.layer.cornerCurve = .continuous
                    var configuration = UIButton.Configuration.filled()
                    configuration.title = "Add Friend"
                    configuration.baseBackgroundColor = UIColor.init(hex: "B8E9FF", alpha: 0.4)
                    configuration.imagePlacement = .trailing
                    configuration.showsActivityIndicator = false
                    configuration.imagePadding = 24
                    noFriendButtonLayout.layer.borderWidth = 4.0
                    noFriendButtonLayout.layer.borderColor = UIColor.white.cgColor
                    noFriendButtonLayout.layer.cornerRadius = 12.0
                    noFriendButtonLayout.layer.cornerCurve = .continuous
                    noFriendLabel.textColor = UIColor.white
                    noFriendButtonLayout.configuration = configuration
                }
                ActivityIndicator.stopAnimating()
                let createStepPointJudge = try await FirebaseClient.shared.checkCreateStepPoint()
                if createStepPointJudge == true {
                    try await Scorering.shared.createStepPoint()
                }
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self!.viewDidAppear(true)
                }
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
        let alert = UIAlertController(title: "今日の獲得ポイントは0ptです", message: "頑張りましょう", preferredStyle: .alert)
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
