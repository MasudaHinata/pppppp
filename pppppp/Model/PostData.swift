import Foundation

struct PostData: Codable {
    var userID: String
    var date: Date
    var activity: String?
    var point: Int?
}
