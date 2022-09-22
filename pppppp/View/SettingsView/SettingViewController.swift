import UIKit
import Combine
import SafariServices

class SettingViewController: UIViewController, SetttingAccountDelegate  {
    
    var cancellables = Set<AnyCancellable>()
    let settingSection = ["Accumulation Type", "Account", "Feedback"]
    let accumulationTypeItems = ["今日までの一週間", "月曜始まり"]
    let accountItems = ["サインアウト", "アカウント削除"]
    let feedbackItems = ["フィードバックを送る"]
    
    @IBOutlet var settingTableView: UITableView! {
        didSet {
            settingTableView.delegate = self
            settingTableView.dataSource = self
            settingTableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingTableViewCell")
            settingTableView.backgroundView = nil
            settingTableView.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.SettingAccountDelegate = self
    }
    
    func logoutButton() {
        let alert = UIAlertController(title: "注意", message: "ログアウトしますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "ログアウト", style: .destructive, handler: { [self] (action) -> Void in
            
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await FirebaseClient.shared.logout()
                }
                catch {
                    print("Setting Logout error", error.localizedDescription)
                    if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in })
                    } else {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                    }
                }
            }
            self.cancellables.insert(.init { task.cancel() })
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
        })
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func deleteAccount() {
        let alert = UIAlertController(title: "注意", message: "アカウントを削除しますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { [self] (action) -> Void in
            
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await FirebaseClient.shared.accountDelete()
                }
                catch {
                    //TODO: error処理
                    print("SettingView deleteAccount error:\(String(describing: error.localizedDescription))")
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "ログインし直してもう一度お試しください", handler: { _ in
                        let storyboard = UIStoryboard(name: "SignInWithAppleView", bundle: nil)
                        let secondVC = storyboard.instantiateInitialViewController()
                        self.showDetailViewController(secondVC!, sender: self)
                    })
                }
            }
            cancellables.insert(.init { task.cancel() })
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
        })
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func sceneGoogleForm() {
        guard let url = URL(string: "https://forms.gle/McVkxngftm1xocvGA") else { return }
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
    }
    
    //MARK: - Setting Delegate
    func accountDeleted() {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        let alert = UIAlertController(title: "完了", message: "アカウントを削除しました", preferredStyle: .alert)
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
    
    func faildAcccountDelete() {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        let alert = UIAlertController(title: "ログインしなおしてもう一度試してください", message: "データが全て消えている可能性があります", preferredStyle: .alert)
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
    
    func faildAcccountDeleteData() {
        let alert = UIAlertController(title: "もう一度試してください", message: "データの削除に失敗しました", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func logoutCompleted() {
        let alert = UIAlertController(title: "完了", message: "ログアウトしました", preferredStyle: .alert)
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
}
