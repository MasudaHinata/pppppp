import UIKit
import Combine
import SafariServices

class SettingViewController: UIViewController, SetttingAccountDelegate  {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "SelectAccumulationTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectAccumulationTypeTableViewCell")
            tableView.backgroundView = nil
            tableView.backgroundColor = .clear
        }
    }
    
    @IBAction func logoutButton() {
        let alert = UIAlertController(title: "注意", message: "ログアウトしますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "ログアウト", style: .destructive, handler: { [self] (action) -> Void in
            
            let task = Task { [weak self] in
                do {
                    try await FirebaseClient.shared.logout()
                }
                catch {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self!.present(alert, animated: true)
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
    @IBAction func deleteAccount() {
        let alert = UIAlertController(title: "注意", message: "アカウントを削除しますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { [self] (action) -> Void in
            
            let task = Task { [weak self] in
                do {
                    try await FirebaseClient.shared.accountDelete()
                }
                catch {
                    print("ChangeProfile deleteAccount error:\(String(describing: error.localizedDescription))")
                    let alert = UIAlertController(title: "エラー", message: "ログインし直してもう一度お試しください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        let storyboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "CreateAccountViewController")
                        self?.showDetailViewController(secondVC, sender: self)
                    }
                    alert.addAction(ok)
                    self?.present(alert, animated: true, completion: nil)
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
    
    @IBAction func sceneGoogleForm() {
        guard let url = URL(string: "https://forms.gle/McVkxngftm1xocvGA") else { return }
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.SettingAccountDelegate = self
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

//MARK: - extension
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAccumulationTypeTableViewCell", for: indexPath) as! SelectAccumulationTypeTableViewCell
        
        let cellBackgroundView = UIView()
        cellBackgroundView.backgroundColor = UIColor.init(hex: "969696", alpha: 0.5)
        cell.selectedBackgroundView = cellBackgroundView
        
        if indexPath.row == 0 {
            cell.selectLabel.text = "今日までの一週間"
        } else if indexPath.row == 1 {
            cell.selectLabel.text = "月曜始まり"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* //FIXME: チェックマークが出ない
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .checkmark
         */
        
        if indexPath.row == 0 {
            UserDefaults.standard.set("今日までの一週間", forKey: "accumulationType")
            let alert = UIAlertController(title: "完了", message: "ポイントの累積タイプを変更しました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                self.showDetailViewController(secondVC, sender: self)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            UserDefaults.standard.set("月曜始まり", forKey: "accumulationType")
            let alert = UIAlertController(title: "完了", message: "ポイントの累積タイプを変更しました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                self.showDetailViewController(secondVC, sender: self)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        print(UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間")
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select accumulation type"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
