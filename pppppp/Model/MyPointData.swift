//
//  MyPointData.swift
//  pppppp
//
//  Created by hinata on 2022/08/30.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct MyPointData: Codable {
    @DocumentID var id: String?
    var point: Int?
}
