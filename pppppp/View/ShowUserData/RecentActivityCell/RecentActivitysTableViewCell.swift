import UIKit

class RecentActivitysTableViewCell: UITableViewCell {
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
