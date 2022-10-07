import UIKit
import Combine

protocol TimelineCollectionViewCellDelegate: AnyObject {
    func tapGoodButton(judge: Bool)
}

class TimelinePostCollectionViewCell: UICollectionViewCell {
    
    var timelineCollectionViewCellDelegate: TimelineCollectionViewCellDelegate?
    var cancellables = Set<AnyCancellable>()
    
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
        var judge: Bool!
        
        let task = Task {
            do {
                try await FirebaseClient.shared.checkUserAuth()
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
            catch {
                print("TimeLineCollection tapGoodButton error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
