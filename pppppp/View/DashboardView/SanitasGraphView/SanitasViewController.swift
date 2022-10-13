import Combine
import UIKit
import SwiftUI

class SanitasViewController: UIViewController, FirebaseEmailVarifyDelegate, FirebasePutPointDelegate, DrawViewDelegate, FireStoreCheckNameDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var cancellables = Set<AnyCancellable>()
    let calendar = Calendar.current
    var startDate = Date()
    var friendDataList = [UserData]()
    var pointDataList = [PointData]()
    
    @IBOutlet var stepsLabel: UILabel!
    @IBOutlet var mountainView: DrawView!
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func sceneDashboardView() {
        let dashboardVC = StoryboardScene.DashboardView.initialScene.instantiate()
        dashboardVC.friendDataList = friendDataList
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
    
    @IBAction func sceneHealthView() {
        let healthChartsVC = HealthChartsViewController(viewModel: HealthChartsViewModel())
        self.navigationController?.pushViewController(healthChartsVC, animated: true)
    }
    
    //MARK: - 体重・運動を記録する
    @IBAction func sceneRecordDataView() {
        if #available(iOS 16.0, *) {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let weightAction = UIAlertAction(title: "体重の記録を追加", style: .default) { _ in
                let recordWeightVC = StoryboardScene.RecordWeightView.initialScene.instantiate()
                if let sheet = recordWeightVC.sheetPresentationController {
                    sheet.detents = [.custom { context in 178 }]
                }
                self.present(recordWeightVC, animated: true, completion: nil)
            }
            let exerciseAction = UIAlertAction(title: "運動の記録を追加", style: .default) { _ in
                let recordExerciseVC = StoryboardScene.RecordExerciseView.initialScene.instantiate()
                if let sheet = recordExerciseVC.sheetPresentationController {
                    sheet.detents = [.custom { context in 178 }]
                }
                self.present(recordExerciseVC, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
            actionSheet.addAction(weightAction)
            actionSheet.addAction(exerciseAction)
            actionSheet.addAction(cancelAction)
            present(actionSheet, animated: true)
        } else {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let weightAction = UIAlertAction(title: "体重の記録を追加", style: .default) { _ in
                let recordWeightVC = StoryboardScene.RecordWeightView.initialScene.instantiate()
                self.present(recordWeightVC, animated: true, completion: nil)
            }
            let exerciseAction = UIAlertAction(title: "運動の記録を追加", style: .default) { _ in
                let recordExerciseVC = StoryboardScene.RecordExerciseView.initialScene.instantiate()
                self.present(recordExerciseVC, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
            actionSheet.addAction(weightAction)
            actionSheet.addAction(exerciseAction)
            actionSheet.addAction(cancelAction)
            present(actionSheet, animated: true)
        }
    }
    
    @IBAction func reloadButton() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                activityIndicator.startAnimating()
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
                stepsLabel.text = "Today  \(Int(try await HealthKit_ScoreringManager.shared.getTodaySteps()))  steps"
                self.friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                mountainView.configure(rect: self.view.bounds, friendListItems: self.friendDataList)
                activityIndicator.stopAnimating()
            }
            catch {
                print("SanitasViewContro reloadButton error:", error.localizedDescription)
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
#if DEBUG
        print("🛠Debug")
#elseif STAGING
        print("🧑🏻‍💻Staging")
#else
        print("📱Release")
#endif

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

        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                activityIndicator.startAnimating()

                let userID = try await FirebaseClient.shared.getUserUUID()
                pointDataList = try await FirebaseClient.shared.getPointData(id: userID)
                pointDataList.reverse()

                let todayPoint = pointDataList.filter { $0.date.getZeroTime() == Date().getZeroTime() }.compactMap { $0.point }

                if todayPoint.reduce(0, +) <= 0 {
                    imageView?.image = UIImage(named: "Rectangle1")
                } else if todayPoint.reduce(0, +) <= 15 {
                    imageView?.image = UIImage(named: "Rectangle2")
                } else if todayPoint.reduce(0, +) <= 40 {
                    imageView?.image = UIImage(named: "Rectangle3")
                } else {
                    imageView?.image = UIImage(named: "Rectangle4")
                }

                //MARK: MountainViewを表示
                self.friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                mountainView.configure(rect: self.view.bounds, friendListItems: self.friendDataList)
                if friendDataList.count == 1 {
                    let addFriendVC = StoryboardScene.AddFriendView.initialScene.instantiate()
                    self.showDetailViewController(addFriendVC, sender: self)
                }

                activityIndicator.stopAnimating()
            } catch {
                print("SanitasViewContro ViewDidL error:",error.localizedDescription)
                if error.localizedDescription == "Authorization not determined" {
                } else if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                        self.viewDidAppear(true)
                    }
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        activityIndicator.startAnimating()
        //MARK: 初期画面
        let judge: Bool = (UserDefaults.standard.object(forKey: "initialScreen") as? Bool) ?? false
        if judge == false {
            let onboardingView1VC = StoryboardScene.OnboardingView1.initialScene.instantiate()
            self.showDetailViewController(onboardingView1VC, sender: self)
        }

        //MARK: MountainViewの位置更新
        mountainView.configure(rect: self.view.bounds, friendListItems: friendDataList)
        if friendDataList.count == 1 {
            let addFriendVC = StoryboardScene.AddFriendView.initialScene.instantiate()
            self.showDetailViewController(addFriendVC, sender: self)
        }
        activityIndicator.stopAnimating()

        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.checkUserAuth()

                //MARK: 今日の歩数を表示
                stepsLabel.text = "Today \(Int(try await HealthKit_ScoreringManager.shared.getTodaySteps())) steps"

                //MARK: 今日の自己評価が完了しているかの判定
                let now = calendar.component(.hour, from: Date())
                if now >= 19 {
                    let selfCheckJudge = try await FirebaseClient.shared.checkSelfCheck()
                    if selfCheckJudge {
                        let selfCheckVC = StoryboardScene.SelfCheckView.initialScene.instantiate()
                        selfCheckVC.modalPresentationStyle = .overFullScreen
                        selfCheckVC.modalTransitionStyle = .crossDissolve
                        self.present(selfCheckVC, animated: true)
                    }
                }
                
                //MARK: 今日の歩数ポイントの作成が完了しているかの判定
                let createStepPointJudge = try await FirebaseClient.shared.checkCreateStepPoint()
                if createStepPointJudge {
                    try await HealthKit_ScoreringManager.shared.createStepPoint()
                }

                //MARK: ワークアウトのポイント作成判定
                let createdPointjudge = try await HealthKit_ScoreringManager.shared.createWorkoutPoint()
                if createdPointjudge == false {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー(Workout point)", message: "HealthKitにデータがないためポイントを作成できませんでした")
                }

                //MARK: 体重のポイント作成判定
                let judge = try await HealthKit_ScoreringManager.shared.checkWeightPoint()
                let userID = try await FirebaseClient.shared.getUserUUID()
                let userData: [UserData] = try await FirebaseClient.shared.getUserDataFromId(friendId: userID)
                guard let goalWeight = userData.last?.weightGoal else {
                    let setGoalWeightVC = StoryboardScene.SetGoalWeightView.initialScene.instantiate()
                    self.showDetailViewController(setGoalWeightVC, sender: self)
                    return
                }
                if judge {
                    let weight = try await HealthKit_ScoreringManager.shared.getWeight()
                    let checkPoint = try await HealthKit_ScoreringManager.shared.createWeightPoint(weightGoal: goalWeight, weight: weight)
                    if checkPoint == [] {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "HealthKitに過去2週間の体重データがないためポイントを作成できませんでした")
                    }
                }
            }
            catch {
                print("SanitasViewContro ViewAppear error:",error.localizedDescription)
                if error.localizedDescription == "Authorization not determined" {
                } else if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                        self.viewDidAppear(true)
                    }
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }

    func buttonSelected(item: UserData) {
        let profileVC = ProfileViewController(viewModel: .init(userDataItem: item))
        self.showDetailViewController(profileVC, sender: self)
    }
    
    //MARK: - Setting Delegate
    func emailVerifyRequiredAlert() {
        let alert = UIAlertController(title: "仮登録が完了していません", message: "メールを確認してください", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let signInWithAppleVC = StoryboardScene.SignInWithAppleView.initialScene.instantiate()
            self.showDetailViewController(signInWithAppleVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func putPointForFirestore(point: Int, activity: String) {
        let alert = UIAlertController(title: "ポイントを獲得しました", message: "\(activity): \(point)pt", preferredStyle: .alert)
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

    func notChangeName() {
        let setNameVC = StoryboardScene.SetNameView.initialScene.instantiate()
        self.showDetailViewController(setNameVC, sender: self)
    }
}
