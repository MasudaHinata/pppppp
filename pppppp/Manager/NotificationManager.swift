import Foundation
import NotificationCenter

class NotificationManager {
    static func setCalendarNotification(title: String, body: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.badge = NSNumber(value: 1)
        notificationContent.sound = .default
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        var datComp = DateComponents()
        datComp.hour = 19
        datComp.minute = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: datComp, repeats: true)
        let request = UNNotificationRequest(identifier: "ID", content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    static func dailyNotification(title: String, body: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.badge = NSNumber(value: 1)
        notificationContent.sound = .default
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        var datComp = DateComponents()
        datComp.hour = 7
        datComp.minute = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: datComp, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyNotification", content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
}
