import Foundation

struct PostData: Codable {
    var name: String
//    var iconImageURL: URL
    var date: Date
    var activity: String?
    var point: Int?
}
