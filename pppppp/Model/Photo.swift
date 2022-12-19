import Foundation
import SwiftUI

struct Photo: Identifiable {
    var id = UUID()
    var image: Image
    var caption: String
    var description: String
}
