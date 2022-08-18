//
//  FriendDataCell.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/29.
//

import UIKit

class FriendDataCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var iconView: UIImageView!
    
    @IBOutlet var profileBackgroundView: UIView! {
        didSet {
            profileBackgroundView.layer.cornerCurve = .continuous
            profileBackgroundView.layer.cornerRadius = 16
            profileBackgroundView.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
