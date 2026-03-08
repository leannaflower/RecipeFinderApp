//
//  NotificationManager.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/2/24.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    init() {    // first request permission to get notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            // success -> whether the user approved
            // error -> if something went wrong
            if !success && error == nil {
                print("Notification not permitted")
            }
        }
    }
    
    // schedule notifications
    func scheduleNotification(date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "This is your scheduled notification"
        content.sound = .default
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(date).")
            }
        }
    }
}
