import UIKit

class ExerciseTableViewCell: UITableViewCell {

    @IBOutlet var exerciseTextField: UITextField!
    @IBOutlet var exerciseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
