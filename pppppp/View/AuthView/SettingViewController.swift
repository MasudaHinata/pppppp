import UIKit
import Combine

class SettingViewController: UIViewController, FirebaseDeleteAccountDelegate  {

    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.deleteAccountDelegate = self
    }
    @IBAction func logoutButton() {
        do {
            let alert3 = UIAlertController(title: "注意", message: "ログアウトしますか？", preferredStyle: .alert)
            let delete = UIAlertAction(title: "ログアウト", style: .destructive, handler: { [self] (action) -> Void in
                
                let task = Task { [weak self] in
                    do {
                        try await FirebaseClient.shared.logout()
                        //FIXME: ここでアラート呼びたくない
                        let alert = UIAlertController(title: "ログアウトしました", message: "ありがとうございました", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                            let storyboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
                            let secondVC = storyboard.instantiateViewController(identifier: "CreateAccountViewController")
                            self!.showDetailViewController(secondVC, sender: self)
                        }
                        alert.addAction(ok)
                        self?.present(alert, animated: true, completion: nil)
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
            alert3.addAction(delete)
            alert3.addAction(cancel)
            self.present(alert3, animated: true, completion: nil)
        }
    }
    @IBAction func deleteAccount() {
        let alert = UIAlertController(title: "注意", message: "アカウントを削除しますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { [self] (action) -> Void in
            
            let task = Task { [weak self] in
                do {
                    try await FirebaseClient.shared.accountDelete()
                }
                catch {
                    print("ChangeProfile deleteAccount210:\(String(describing: error.localizedDescription))")
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
    
    //MARK: - Setting Delegate
    func accountDeleted() {
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
        let alert = UIAlertController(title: "エラーログインしなおしてもう一度試してください", message: "データが全て消えている可能性があります", preferredStyle: .alert)
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
}
