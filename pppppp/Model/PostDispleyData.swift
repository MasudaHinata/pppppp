import Foundation
import FirebaseFirestoreSwift

struct PostDisplayData: Codable { 
    var postData: PostData
    var createdUser: UserData
}

