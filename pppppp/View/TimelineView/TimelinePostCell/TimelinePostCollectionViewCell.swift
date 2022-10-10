import UIKit
import Combine

protocol TimelineCollectionViewCellDelegate: AnyObject {
    func tapGoodButton(judge: Bool, postId: String)
}

class TimelinePostCollectionViewCell: UICollectionViewCell {
    
    var timelineCollectionViewCellDelegate: TimelineCollectionViewCellDelegate?
    var cancellables = Set<AnyCancellable>()
    
    var postDisplayData: PostDisplayData?
    let dateFormatter = DateFormatter()
    
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var pointLabel: UILabel!
    @IBOutlet private var activityLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var activityImageView: UIImageView!
    @IBOutlet private var userIconImageView: UIImageView! {
        didSet {
            userIconImageView.layer.cornerRadius = 32
            userIconImageView.clipsToBounds = true
            userIconImageView.layer.cornerCurve = .continuous
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Configure Cell
    func configureCell(_ postDisplayData: PostDisplayData) {
        dateFormatter.dateFormat = "YY/MM/dd HH:mm"
        self.postDisplayData = postDisplayData
        userNameLabel.text = postDisplayData.createdUser.name
        userIconImageView.kf.setImage(with: URL(string: postDisplayData.createdUser.iconImageURL))
        dateLabel.text = "\(dateFormatter.string(from: postDisplayData.postData.date))"
        pointLabel.text = "\(postDisplayData.postData.point) pt"
        activityLabel.text = postDisplayData.postData.activity

        let activityImageName = postDisplayData.postData.activity.imageName
        activityImageView.image = UIImage(systemName: activityImageName)

    }
}
