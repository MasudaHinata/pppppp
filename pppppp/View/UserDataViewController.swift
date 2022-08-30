//
//  UserDataViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/30.
//

import UIKit
import Combine

class UserDataViewController: UIViewController {

    var cancellables = Set<AnyCancellable>()
    var userDataItem: UserData?
    @IBOutlet var namelabel: UILabel!
    @IBOutlet var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 32
            iconView.clipsToBounds = true
            iconView.layer.cornerCurve = .continuous
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        iconView.kf.setImage(with: URL(string: userDataItem!.iconImageURL))
        namelabel.text = userDataItem?.name
    }
}
