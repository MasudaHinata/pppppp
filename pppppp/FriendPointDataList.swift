//
//  FriendPointDataList.swift
//  pppppp
//
//  Created by hinata on 2022/08/26.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct FriendPointDataList: Codable {
    @DocumentID var id: String?
    let point: Int?
    var date: Timestamp?
}
