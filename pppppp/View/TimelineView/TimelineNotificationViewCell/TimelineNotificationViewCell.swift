import UIKit

class TimelineNotificationViewCell: UICollectionViewCell {
    
    @IBOutlet var friendIconView: UIImageView! {
        didSet {
            friendIconView.layer.cornerRadius = 36
            friendIconView.clipsToBounds = true
            friendIconView.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var friendNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

