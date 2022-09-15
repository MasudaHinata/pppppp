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
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    print("Change Logout error", error.localizedDescription)
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
                    print("ChangeProfile deleteAccount error:\(String(describing: error.localizedDescription))")
                    let alert = UIAlertController(title: "エラー", message: "ログインし直してもう一度お試しください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        let storyboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "CreateAccountViewController")
                        self.showDetailViewController(secondVC, sender: self)
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
            let secondVC = storyboard.instantiateViewController(identifier: "CreateAccountViewController")
            self.showDetailViewController(secondVC, sender: self)
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
            let secondVC = storyboard.instantiateViewController(identifier: "CreateAccountViewController")
            self.showDetailViewController(secondVC, sender: self)
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
            let secondVC = storyboard.instantiateViewController(identifier: "CreateAccountViewController")
            self.showDetailViewController(secondVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Setting TableView
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 0) {
            return 2
        } else if (tableView.tag == 1) {
            return 2
        } else if (tableView.tag == 2) {
            return 1
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellBackgroundView = UIView()
        cellBackgroundView.backgroundColor = UIColor.init(hex: "969696", alpha: 0.5)
        if (tableView.tag == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAccumulationTypeTableViewCell", for: indexPath) as! SelectAccumulationTypeTableViewCell
            cell.selectedBackgroundView = cellBackgroundView
            cell.accessoryType = .none

            let accumulationType = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
            if indexPath.row == 0 {
                cell.selectLabel.text = "今日までの一週間"
                if accumulationType as! String == "今日までの一週間" {
                    cell.accessoryType = .checkmark
                }
            } else if indexPath.row == 1 {
                cell.selectLabel.text = "月曜始まり"
                if accumulationType as! String == "月曜始まり" {
                    cell.accessoryType = .checkmark
                }
            }
            return cell
        } else if (tableView.tag == 1) {
            let accountCell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
            accountCell.selectedBackgroundView = cellBackgroundView
            accountCell.settingAccountLabel.textColor = .systemPink
            if indexPath.row == 0 {
                accountCell.settingAccountLabel.text = "サインアウト"
            } else if indexPath.row == 1 {
                accountCell.settingAccountLabel.text = "アカウント削除"
            }
            return accountCell
        } else if (tableView.tag == 2) {
            let feedbackCell = tableView.dequeueReusableCell(withIdentifier: "FeedbackTableViewCell", for: indexPath) as! FeedbackTableViewCell
            feedbackCell.selectedBackgroundView = cellBackgroundView
            if indexPath.row == 0 {
                feedbackCell.FeedbackLabel.text = "フィードバックを送る"
            }
            return feedbackCell
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.tag == 0) {
            
            if indexPath.row == 0 {
                UserDefaults.standard.set("今日までの一週間", forKey: "accumulationType")
                tableView.reloadData()
                let alert = UIAlertController(title: "ポイントの累積タイプを変更しました", message: "今日までの一週間", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                    self.showDetailViewController(secondVC, sender: self)
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                UserDefaults.standard.set("月曜始まり", forKey: "accumulationType")
                tableView.reloadData()
                let alert = UIAlertController(title: "ポイントの累積タイプを変更しました", message: "月曜始まり", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                    self.showDetailViewController(secondVC, sender: self)
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
//            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        } else if (tableView.tag == 1) {
            if indexPath.row == 0 {
                logoutButton()
            } else if indexPath.row == 1 {
                deleteAccount()
            }
//            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        } else if (tableView.tag == 2) {
            if indexPath.row == 0 {
                sceneGoogleForm()
            }
//            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        } else {
            fatalError("collectionView Tag Invalid")
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (tableView.tag == 0) {
            return "point accumulation type"
        } else if (tableView.tag == 1) {
            return "account"
        } else if (tableView.tag == 2) {
            return "feedback"
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView.tag == 0) {
            return 30
        } else if (tableView.tag == 1) {
            return 30
        } else if (tableView.tag == 2) {
            return 30
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }
}
