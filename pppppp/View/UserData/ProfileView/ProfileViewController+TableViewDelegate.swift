//import UIKit
//
//extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        pointDataList.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentActivitysTableViewCell", for: indexPath) as! RecentActivitysTableViewCell
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd"
//        let dataStr = dateFormatter.string(from: pointDataList[indexPath.row].date)
//        cell.pointLabel.text = "+\(pointDataList[indexPath.row].point ?? 0)pt"
//        cell.dateLabel.text = dataStr
//        cell.activityLabel.text = pointDataList[indexPath.row].activity ?? ""
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        //ヘッダーの肥大化を回避
//        return "  "
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 4
//    }
//}
