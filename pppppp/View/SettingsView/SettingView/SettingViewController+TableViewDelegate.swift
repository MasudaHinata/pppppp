import UIKit

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSection.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingSection[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 24
        } else if section == 1 {
            return 24
        } else if section == 2 {
            return 24
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return accumulationTypeItems.count
        } else if section == 1 {
            return accountItems.count
        } else if section == 2 {
            return feedbackItems.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        
        let cellBackgroundView = UIView()
        cellBackgroundView.backgroundColor = Asset.Colors.gray50.color
        cell.selectedBackgroundView = cellBackgroundView
        
        if indexPath.section == 0 {
            cell.textLabel?.textColor = .white
            cell.accessoryType = .none
            let accumulationType = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
            if indexPath.row == 0 {
                if accumulationType as! String == "今日までの一週間" {
                    cell.accessoryType = .checkmark
                }
            } else if indexPath.row == 1 {
                if accumulationType as! String == "月曜始まり" {
                    cell.accessoryType = .checkmark
                }
            }
            cell.textLabel?.text = "\(accumulationTypeItems[indexPath.row])"
        } else if indexPath.section == 1 {
            //TODO: アカウント削除だけ赤色にする(サインアウトも赤くなってる)
            cell.textLabel?.textColor = .red
            cell.accessoryType = .none
            cell.textLabel?.text = "\(accountItems[indexPath.row])"
        } else if indexPath.section == 2 {
            cell.accessoryType = .none
            cell.textLabel?.text = "\(feedbackItems[indexPath.row])"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                UserDefaults.standard.set("今日までの一週間", forKey: "accumulationType")
                tableView.reloadData()
                ShowAlertHelper.okAlert(vc: self, title: "ポイントの累積タイプを変更しました", message: "今日までの一週間") { _ in
                    let mainVC = StoryboardScene.Main.initialScene.instantiate()
                    self.showDetailViewController(mainVC, sender: self)
                }
            } else if indexPath.row == 1 {
                UserDefaults.standard.set("月曜始まり", forKey: "accumulationType")
                tableView.reloadData()
                ShowAlertHelper.okAlert(vc: self, title: "ポイントの累積タイプを変更しました", message: "月曜始まり") { _ in
                    let mainVC = StoryboardScene.Main.initialScene.instantiate()
                    self.showDetailViewController(mainVC, sender: self)
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                logoutButton()
            } else if indexPath.row == 1 {
                deleteAccount()
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                sceneGoogleForm()
            }
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}
