//
//  MyProfileData.swift
//  pppppp
//
//  Created by hinata on 2022/08/29.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct MyProfileData: Codable {
    @DocumentID var id: String?
    let name: String
    let IconImageURL: String
    var point: Int?
    var date: Timestamp?
}
