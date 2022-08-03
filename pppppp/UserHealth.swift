//
//  UserHealth.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/03.
//

import Foundation
import FirebaseFirestoreSwift

struct UserHealth: Codable {
    @DocumentID var id: String?
    let point: String
}
