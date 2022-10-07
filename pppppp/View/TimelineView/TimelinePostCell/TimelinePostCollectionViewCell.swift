import UIKit

protocol TimelineCollectionViewCellDelegate: AnyObject {
    func tapGoodButton()
}

class TimelinePostCollectionViewCell: UICollectionViewCell {
    
    var timelineCollectionViewCellDelegate: TimelineCollectionViewCellDelegate?
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var goodButton: UIButton!
    @IBOutlet var userIconImageView: UIImageView! {
        didSet {
            userIconImageView.layer.cornerRadius = 36
            userIconImageView.clipsToBounds = true
            userIconImageView.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func tapGoodButton(_ sender: Any) {
        
        if goodButton.currentImage == UIImage.init(systemName: "heart.fill") {
            goodButton.setImage(UIImage.init(systemName: "heart"), for: .normal)
        } else {
            goodButton.setImage(UIImage.init(systemName: "heart.fill"), for: .normal)
        }
           
        timelineCollectionViewCellDelegate?.tapGoodButton()
       }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
}
