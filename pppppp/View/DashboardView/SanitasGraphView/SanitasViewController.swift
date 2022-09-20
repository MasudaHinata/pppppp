import Combine
import UIKit
import SwiftUI

class SanitasViewController: UIViewController, FirebaseEmailVarifyDelegate ,FirebasePutPointDelegate, DrawViewDelegate, FireStoreCheckNameDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var cancellables = Set<AnyCancellable>()
    let calendar = Calendar.current
    var startDate = Date()
    let dateFormatter = DateFormatter()
    var friendIdList = [String]()
    var friendDataList = [UserData]()
    
    @IBOutlet var stepsLabel: UILabel!
    @IBOutlet var weekPointLabel: UILabel!
    @IBOutlet var noFriendView: UIView!
    @IBOutlet var noFriendLabel: UILabel!
    @IBOutlet var mountainView: DrawView!
    
    @IBAction func sceneCollectionView() {
        let storyboard = UIStoryboard(name: "DashboardView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
    
    @IBAction func sceneHealthDataView() {
        let storyboard = UIStoryboard(name: "HealthDataView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
    
    @IBAction func reloadButton() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                activityIndicator.startAnimating()
                stepsLabel.text = "Today  \(Int(try await Scorering.shared.getTodaySteps())) steps"
                self.friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                mountainView.configure(rect: self.view.bounds, friendListItems: self.friendDataList)
                activityIndicator.stopAnimating()
            }
            catch {
                print("ViewContro reloadButton error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { (_) in
                        self.viewDidAppear(true)
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { (_) in })
                }
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
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        mountainView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        //初期画面
        let judge: Bool = (UserDefaults.standard.object(forKey: "initialScreen") as? Bool) ?? false
        if judge == false {
            let storyboard = UIStoryboard(name: "OnboardingView1", bundle: nil)
            let secondVC = storyboard.instantiateInitialViewController()
            self.showDetailViewController(secondVC!, sender: self)
        }
        
        mountainView.configure(rect: self.view.bounds, friendListItems: friendDataList)
        if friendDataList.count == 1 {
            let storyboard = UIStoryboard(name: "AddFriendView", bundle: nil)
            let secondVC = storyboard.instantiateInitialViewController()
            self.showDetailViewController(secondVC!, sender: self)
        }
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.userAuthCheck()
                let now = calendar.component(.hour, from: Date())
                if now >= 19 {
                    let selfCheckJudge = try await FirebaseClient.shared.checkSelfCheck()
                    if selfCheckJudge {
                        let storyboard = UIStoryboard(name: "SelfCheckView", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "SelfCheckViewController")
                        secondVC.modalPresentationStyle = .overFullScreen
                        secondVC.modalTransitionStyle = .crossDissolve
                        self.present(secondVC, animated: true)
                    }
                }
                let createStepPointJudge = try await FirebaseClient.shared.checkCreateStepPoint()
                if createStepPointJudge {
                    try await Scorering.shared.createStepPoint()
                }
                
                self.friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                mountainView.configure(rect: self.view.bounds, friendListItems: self.friendDataList)
                if friendDataList.count == 1 {
                    let storyboard = UIStoryboard(name: "AddFriendView", bundle: nil)
                    let secondVC = storyboard.instantiateInitialViewController()
                    self.showDetailViewController(secondVC!, sender: self)
                }
                activityIndicator.stopAnimating()
                
                let userID = try await FirebaseClient.shared.getUserUUID()
                let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
                if type as! String == "今日までの一週間" {
                    startDate = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: Date()))!
                } else if type as! String == "月曜始まり" {
                    let am = calendar.startOfDay(for: Date())
                    let weekNumber = calendar.component(.weekday, from: am)
                    if weekNumber == 1 {
                        startDate = calendar.date(byAdding: .day, value: -6, to: am)!
                    } else {
                        startDate = calendar.date(byAdding: .day, value: -(weekNumber - 2), to: am)!
                    }
                }
                dateFormatter.dateFormat = "MM/dd"
                weekPointLabel.text = "\(dateFormatter.string(from: startDate)) ~ Today  \(try await FirebaseClient.shared.getPointDataSum(id: userID, accumulationType: type as! String))  pt"
                stepsLabel.text = "Today  \(Int(try await Scorering.shared.getTodaySteps()))  steps"
            }
            catch {
                print("ViewContro ViewAppear error:",error.localizedDescription)
                if error.localizedDescription == "Authorization not determined" {
                } else if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { (_) in
                        self.viewDidAppear(true)
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { (_) in })
                }
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - Setting Delegate
    func emailVerifyRequiredAlert() {
        let alert = UIAlertController(title: "仮登録が完了していません", message: "メールを確認してください", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "SignInWithAppleView", bundle: nil)
            let secondVC = storyboard.instantiateInitialViewController()
            self.showDetailViewController(secondVC!, sender: self)
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
        let secondVC = storyboard.instantiateInitialViewController() as! UserDataViewController
        secondVC.userDataItem = item
        self.showDetailViewController(secondVC, sender: self)
    }
    func notChangeName() {
        let storyboard = UIStoryboard(name: "SetNameView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
}
