import UIKit

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
            if indexPath.row == 0 {
                accountCell.settingAccountLabel.text = "サインアウト"
            } else if indexPath.row == 1 {
                accountCell.settingAccountLabel.textColor = .red
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
        } else if (tableView.tag == 1) {
            if indexPath.row == 0 {
                logoutButton()
            } else if indexPath.row == 1 {
                deleteAccount()
            }
        } else if (tableView.tag == 2) {
            if indexPath.row == 0 {
                sceneGoogleForm()
            }
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
