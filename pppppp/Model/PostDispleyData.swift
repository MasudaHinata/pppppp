import Foundation
import FirebaseFirestoreSwift

struct PostDisplayData: Codable {
//    var id: String?
//    var userID: String
//    var date: Date
//    var activity: String
//    var point: Int
//    var likeFriendList: [String]
//    var name: String
//    var iconImageURL: URL
    
    var postData: PostData
    var createdUser: UserData
}

