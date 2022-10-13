import Foundation
import FirebaseFirestoreSwift

struct UserData: Codable {
    @DocumentID var id: String?
    let name: String
    let iconImageURL: String
    var point: Int?
    var weightGoal: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconImageURL = "IconImageURL"
        case point
        case weightGoal
    }
}
