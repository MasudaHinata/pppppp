import UIKit

class TimelineNotificationViewController: UIViewController {

    var postData: PostDisplayData?
    let dateFormatter = DateFormatter()
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
//    @IBOutlet var goodButton: UIButton!
    @IBOutlet var userIconImageView: UIImageView! {
        didSet {
            userIconImageView.layer.cornerRadius = 36
            userIconImageView.clipsToBounds = true
            userIconImageView.layer.cornerCurve = .continuous
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        
        userNameLabel.text = postData?.name
        pointLabel.text = "\(postData?.point ?? 0)"
        activityLabel.text = postData?.activity
        dateLabel.text = "\(dateFormatter.string(from: postData!.date))"
        userIconImageView.kf.setImage(with: postData?.iconImageURL)
    }
}
