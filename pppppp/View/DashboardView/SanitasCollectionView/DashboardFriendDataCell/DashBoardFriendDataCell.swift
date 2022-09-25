import UIKit

class DashBoardFriendDataCell: UICollectionViewCell {
    
    @IBOutlet var rankingLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dataLabel: UILabel!
    @IBOutlet var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 28
            iconView.layer.cornerCurve = .continuous
            iconView.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
