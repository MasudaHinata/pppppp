//
//  User.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/28.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {
    @DocumentID var id: String?
    let name: String
}


