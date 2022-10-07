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
//           //お気に入り状態を取得
//           let isFavorite = UserDefaults.standard.bool(forKey: displayFruits)
//           //表示画像を切り替える
//           if isFavorite {
//               goodButton.setImage(UIImage.init(systemName: "hand.thumbsup"), for: .normal)
//           } else {
//               goodButton.setImage(UIImage.init(systemName: "hand.thumbsup.fill"), for: .normal)
//           }
        
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
