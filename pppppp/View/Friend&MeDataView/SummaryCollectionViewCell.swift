import UIKit

class SummaryCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 2.4
        self.layer.cornerCurve = .continuous
        self.clipsToBounds = true
    }
}
