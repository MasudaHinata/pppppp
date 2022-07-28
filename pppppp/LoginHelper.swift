//
//  LoginHelper.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/07/24.
//

import Foundation
import UIKit

@MainActor
class LoginHelper {
    static let shared = LoginHelper()
    private init() {}
    var viewController: UIViewController?
    
    func showAccountViewController() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let accountVC: AccountViewController = mainStoryboard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
        viewController?.present(accountVC, animated: true, completion: nil)
    }
    
    func showProfileNameViewController() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileNameVC: ProfileNameViewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileNameViewController") as! ProfileNameViewController
        viewController?.present(profileNameVC, animated: true, completion: nil)
    }
}
