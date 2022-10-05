import Foundation

struct PostDisplayData: Codable {
    var userID: String
    var date: Date
    var activity: String
    var point: Int
    var name: String
    var iconImageURL: URL
}

