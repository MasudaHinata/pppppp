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
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "CreateAccountView", bundle: nil)
        let accountVC: CreateAccountViewController = mainStoryboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        viewController?.present(accountVC, animated: true, completion: nil)
    }
}
