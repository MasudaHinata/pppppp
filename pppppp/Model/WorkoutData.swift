import Foundation
import HealthKit

struct WorkoutData: Identifiable {
    var date: String
    var activityTypeID: Int
    var time: Int
    var energy: HKQuantity
    var id = UUID()
}
