import UIKit

class FriendDataCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 28
            iconView.clipsToBounds = true
            iconView.layer.cornerCurve = .continuous
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
