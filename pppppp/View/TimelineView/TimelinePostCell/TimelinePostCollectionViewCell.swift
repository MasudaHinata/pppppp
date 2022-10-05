import UIKit

class TimelinePostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var userIconImageView: UIImageView! {
        didSet {
            userIconImageView.layer.cornerRadius = 36
            userIconImageView.clipsToBounds = true
            userIconImageView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
}
