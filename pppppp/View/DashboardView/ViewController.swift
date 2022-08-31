import Combine
import UIKit
import SwiftUI
import Kingfisher

class ViewController: UIViewController, UITextFieldDelegate, FirebaseEmailVarifyDelegate ,FirebasePutPointDelegate, DrawViewDelegate {
    
    var cancellables = Set<AnyCancellable>()
    var friendIdList = [String]()
    var friendDataList = [UserData]()
    let UD = UserDefaults.standard
    let calendar = Calendar.current
    @IBOutlet var mountainView: DrawView!
    @IBAction func sendCollectionView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "CollectionViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    @IBAction func dataputButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "HealthDataViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseClient.shared.emailVerifyDelegate = self
        FirebaseClient.shared.putPointDelegate = self
        NotificationManager.setCalendarNotification(title: "自己評価をしてポイントを獲得しましょう", body: "19時になりました")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            if UD.object(forKey: "sss") != nil {
                let past_day = UD.object(forKey: "sss") as! Date
                let noww = calendar.component(.day, from: Date())
                let past = calendar.component(.day, from: past_day)
                if noww != past {
                    judgge = true
                } else {
                    judgge = false
                }
            } else {
                judgge = true
                UD.set(Date(), forKey: "sss")
            }
            if judgge {
                judgge = false
                UD.set(Date(), forKey: "sss")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "SelfAssessmentViewController")
                self.showDetailViewController(secondVC, sender: self)
            }
        }
        let task = Task { [weak self] in
            do {
                try await FirebaseClient.shared.userAuthCheck()
                try await FirebaseClient.shared.checkNameData()
                try await FirebaseClient.shared.checkIconData()
                try await Scorering.shared.createStepPoint()
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                mountainView.configure(rect: self!.view.bounds, friendListItems: friendDataList)
                mountainView.delegate = self
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self!.viewDidAppear(true)
                }
                alert.addAction(ok)
                self!.present(alert, animated: true, completion: nil)
                print("ViewContro ViewAppaer error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
        
    }
    func emailVerifyRequiredAlert() {
        let alert = UIAlertController(title: "仮登録が完了していません", message: "メールを確認してください", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "UserDataViewController") as UserDataViewController
        secondVC.userDataItem = item
        self.showDetailViewController(secondVC, sender: self)
    }
}
