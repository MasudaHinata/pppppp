//
//  FriendPointDataList.swift
//  pppppp
//
//  Created by hinata on 2022/08/26.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct PointData: Codable {
    @DocumentID var id: String?
    var point: Int?
}
