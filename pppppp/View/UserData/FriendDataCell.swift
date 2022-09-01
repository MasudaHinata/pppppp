//
//  FriendDataCell.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/29.
//

import UIKit

class FriendDataCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 24
            iconView.clipsToBounds = true
            iconView.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var profileBackgroundView: UIView! {
        didSet {
            profileBackgroundView.layer.cornerRadius = 32
            profileBackgroundView.layer.masksToBounds = true
            profileBackgroundView.layer.cornerCurve = .continuous
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
