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
    @IBOutlet private var likeFriendCountLabel: UILabel!
    @IBOutlet private var heartButton: UIButton!
    @IBOutlet private var userIconImageView: UIImageView! {
        didSet {
            userIconImageView.layer.cornerRadius = 36
            userIconImageView.clipsToBounds = true
            userIconImageView.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func tapGoodButton(_ sender: Any) {
        let task = Task {
            do {
                try await FirebaseClient.shared.checkUserAuth()
                let judge: Bool?
               
                if heartButton.currentImage == UIImage(systemName: "heart.fill") {
                    //MARK: Post good cancell
                    heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    judge = false
                } else {
                    //MARK: Post good
                    heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    judge = true
                }
                
                if let judge = judge, let postId = postDisplayData?.postData.id {
                    timelineCollectionViewCellDelegate?.tapGoodButton(judge: judge, postId: postId)
                }
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
    
    //MARK: - Configure Cell
    func configureCell(_ postDisplayData: PostDisplayData) {
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        self.postDisplayData = postDisplayData
        userNameLabel.text = postDisplayData.createdUser.name
        userIconImageView.kf.setImage(with: URL(string: postDisplayData.createdUser.iconImageURL))
        dateLabel.text = "\(dateFormatter.string(from: postDisplayData.postData.date))"
        pointLabel.text = "\(postDisplayData.postData.point) pt"
        activityLabel.text = postDisplayData.postData.activity

        let task = Task {
            do {
                likeFriendCountLabel.text = "\(try await FirebaseClient.shared.getPostLikeFriendCount(postId: postDisplayData.postData.id ?? ""))"
                
                let userID = try await FirebaseClient.shared.getUserUUID()
                var likedFriendDataList = [UserData]()
                likedFriendDataList = try await FirebaseClient.shared.getPostLikeFriendDate(postId: postDisplayData.postData.id ?? "")
                if likedFriendDataList.first { $0.id == userID } != nil {
                    heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            } catch {
                print("TimelinePostCollection tapGoodButton error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}
