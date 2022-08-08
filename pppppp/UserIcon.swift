//
//  UserIcon.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/08.
//

import Foundation
import FirebaseFirestoreSwift

class UserIcon: Codable {
    @DocumentID var id: String?
    var imageURL: String

//    init(document: QueryDocumentSnapshot) {
//        let postDic = document.data()
//        self.imageURL = postDic["imageURL"] as? String
//    }
}
