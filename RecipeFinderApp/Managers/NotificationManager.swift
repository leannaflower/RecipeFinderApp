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
    func scheduleNotification(date: Date, recipeTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Time to cook! 🍳"
        content.body = "Don't forget to make \(recipeTitle) today."
        content.sound = .default
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(recipeTitle) at \(date).")
            }
        }
    }
}
