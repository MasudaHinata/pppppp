//
//  NotificationManager.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/19.
//

import Foundation
import NotificationCenter

class NotificationManager {
    
    static func setCalendarNotification(title: String, body: String) {
        UserNotifications.UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { granted, error in
            if granted {
                let dateComponents = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: 19, minute: 00)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = title
                notificationContent.body = body
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
}
