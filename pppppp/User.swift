//
//  User.swift
//  pppppp
//
//  Created by 増田ひなた on 2021/05/19.
//

import Foundation
import Firebase

struct AppUser {
    let userID: String
    let userName: String

    init(data: [String: Any]) {
        userID = data["userID"] as! String
        userName = data["userName"] as! String
    }
}
