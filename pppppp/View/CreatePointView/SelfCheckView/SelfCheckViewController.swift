import UIKit
import Combine

class SelfCheckViewController: UIViewController, FirebasePutPointDelegate {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var myIconView: UIImageView! {
        didSet {
            myIconView.layer.cornerRadius = 32
            myIconView.clipsToBounds = true
            myIconView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var myPointLabelButton: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "---pt"
            configuration.baseBackgroundColor = Asset.Colors.lightBlue00.color
            configuration.cornerStyle = .capsule
            myPointLabelButton.configuration = configuration
        }
    }
    
    @IBOutlet var backgroundView: UIView! {
        didSet {
            backgroundView.layer.cornerRadius = 40
            backgroundView.layer.masksToBounds = true
            backgroundView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var goodButton: UIButton! {
        didSet {
            goodButton.layer.cornerRadius = 30
            goodButton.layer.cornerCurve = .continuous
            goodButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var normalButton: UIButton! {
        didSet {
            normalButton.layer.cornerRadius = 30
            normalButton.layer.cornerCurve = .continuous
            normalButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var badButton: UIButton! {
        didSet {
            badButton.layer.cornerRadius = 30
            badButton.layer.cornerCurve = .continuous
            badButton.layer.masksToBounds = true
        }
    }
    
    @IBAction func goodButtonPressed(){
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.firebasePutData(point: 7, activity: "SelfCheck")
                try await FirebaseClient.shared.putSelfCheckLog(log: "good")
            }
            catch {
                print("SelfViewCotro goodButton error:", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message:  "インターネット接続を確認してください")
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    @IBAction func normalButtonPressed(){
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.firebasePutData(point: 5, activity: "SelfCheck")
                try await FirebaseClient.shared.putSelfCheckLog(log: "normal")
            }
            catch {
                print("SelfViewCotro normalButton error", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message:  "インターネット接続を確認してください")
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message:  "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    @IBAction func badButtonPressed(){
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.firebasePutData(point: 3, activity: "SelfCheck")
                try await FirebaseClient.shared.putSelfCheckLog(log: "bad")
            }
            catch {
                print("SelfViewCotro badButton error", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください")
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message:  "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.putPointDelegate = self
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                try await FirebaseClient.shared.checkNameData()
                try await FirebaseClient.shared.checkIconData()

                myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"))

                var configuration = UIButton.Configuration.filled()
                let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
                try await configuration.title = "\(FirebaseClient.shared.getPointDataSum(id: userID, accumulationType: type as! String))pt"
                configuration.baseBackgroundColor = Asset.Colors.lightBlue00.color
                configuration.cornerStyle = .capsule
                myPointLabelButton.configuration = configuration
            }
            catch {
                print("SelfCheckViewCotro viewApe", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください")
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - Setting Delegate
    func putPointForFirestore(point: Int, activity: String) {
        let alert = UIAlertController(title: "ポイントを獲得しました", message: "\(activity): \(point)pt", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
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
}
