//
//  DashBoardFriendDataCell.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/07/17.
//

import UIKit

class DashBoardFriendDataCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dataLabel: UILabel!
    @IBOutlet var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 24
            iconView.layer.cornerCurve = .continuous
            iconView.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 32
        self.layer.cornerCurve = .continuous
        self.clipsToBounds = true
    }
}
