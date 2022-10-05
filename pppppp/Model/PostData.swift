import Foundation
import FirebaseFirestoreSwift

struct PostData: Codable {
    @DocumentID var id: String?
    var userID: String
    var date: Date
    var activity: String
    var point: Int
}
