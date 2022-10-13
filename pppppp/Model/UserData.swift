import Foundation
import FirebaseFirestoreSwift

struct UserData: Identifiable, Codable {
    @DocumentID var id: String?
    let code = UUID()
    let name: String
    let iconImageURL: String
    var point: Int?
    var weightGoal: Double?
    var createWorkoutPointDate: Date?
    var createWeightPointDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case code
        case id
        case name
        case iconImageURL = "IconImageURL"
        case point
        case weightGoal
        case createWorkoutPointDate
        case createWeightPointDate
    }
}
