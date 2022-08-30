//
//  PointHistoryCollectionViewCell.swift
//  pppppp
//
//  Created by hinata on 2022/08/30.
//

import UIKit

class PointHistoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 32
        self.layer.cornerCurve = .continuous
        self.clipsToBounds = true
    }
}

