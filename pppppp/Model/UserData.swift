import Foundation
import Firebase
import FirebaseFirestoreSwift

struct UserData: Codable {
    @DocumentID var id: String?
    let name: String
    let iconImageURL: String
    var point: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconImageURL = "IconImageURL"
        case point
    }
}
