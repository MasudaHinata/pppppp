import Foundation
import Firebase
import FirebaseFirestoreSwift

struct PointData: Codable {
    @DocumentID var id: String?
    var point: Int?
    var date: Date
}
