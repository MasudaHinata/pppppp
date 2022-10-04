import Foundation

struct PostData: Codable {
    var userID: String
//    var name: String
//    var iconImageURL: URL
    var date: Date
    var activity: String?
    var point: Int?
}
