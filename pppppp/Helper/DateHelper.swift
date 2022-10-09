import UIKit

extension Date {
    func getZeroTime() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
