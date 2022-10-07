import UIKit

protocol TimelineCollectionViewCellDelegate: AnyObject {
    func tapGoodButton(judge: Bool)
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
        
        let judge: Bool!
        
        if goodButton.currentImage == UIImage.init(systemName: "heart.fill") {
            //MARK: Post good cancell
            goodButton.setImage(UIImage.init(systemName: "heart"), for: .normal)
            judge = false
        } else {
            //MARK: Post good
            goodButton.setImage(UIImage.init(systemName: "heart.fill"), for: .normal)
            judge = true
        }
        timelineCollectionViewCellDelegate?.tapGoodButton(judge: judge!)
       }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
}
