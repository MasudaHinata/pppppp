//
//  FriendListItem.swift
//  pppppp
//
//  Created by hinata on 2022/08/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FriendListItem: Codable {
    @DocumentID var id: String?
    let name: String
    let IconImageURL: String
//    var point: Int?
}
