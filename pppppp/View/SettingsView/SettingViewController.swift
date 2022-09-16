import UIKit
import Combine
import SafariServices

class SettingViewController: UIViewController, SetttingAccountDelegate  {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var accumulationTypetableView: UITableView! {
        didSet {
            accumulationTypetableView.delegate = self
            accumulationTypetableView.dataSource = self
            accumulationTypetableView.register(UINib(nibName: "SelectAccumulationTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectAccumulationTypeTableViewCell")
            accumulationTypetableView.backgroundView = nil
            accumulationTypetableView.backgroundColor = .clear
        }
    }
    
    @IBOutlet var accountTableView: UITableView! {
        didSet {
            accountTableView.delegate = self
            accountTableView.dataSource = self
            accountTableView.register(UINib(nibName: "AccountTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountTableViewCell")
            accountTableView.backgroundView = nil
            accountTableView.backgroundColor = .clear
        }
    }
    
    @IBOutlet var feedbackTableView: UITableView! {
        didSet {
            feedbackTableView.delegate = self
            feedbackTableView.dataSource = self
            feedbackTableView.register(UINib(nibName: "FeedbackTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedbackTableViewCell")
            feedbackTableView.backgroundView = nil
            feedbackTableView.backgroundColor = .clear
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
                    print("Change Logout error", error.localizedDescription)
                    if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                        let alert = UIAlertController(title: "エラー", message: "インターネット接続を確認してください", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default)
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
                    print("ChangeProfile deleteAccount error:\(String(describing: error.localizedDescription))")
                    let alert = UIAlertController(title: "エラー", message: "ログインし直してもう一度お試しください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        let storyboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
                        let secondVC = storyboard.instantiateInitialViewController()
                        self.showDetailViewController(secondVC!, sender: self)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
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
            let storyboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
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
            let storyboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
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
            let storyboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
            let secondVC = storyboard.instantiateInitialViewController()
            self.showDetailViewController(secondVC!, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
