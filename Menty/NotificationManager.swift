//
//  NotificationManager.swift
//  MentyUITests
//
//  Created by Nicholas Chan on 5/6/23.
//

import Foundation
import UserNotifications

public class NotificationManager {
    public static func scheduleNotification(for reminder: String, at date: Date, withIdentifier identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    public static func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
