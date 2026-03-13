//
//  RemindersView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 3/8/26.
//

import SwiftUI
import UserNotifications

struct RemindersView: View {
    @State private var pendingReminders: [UNNotificationRequest] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                if pendingReminders.isEmpty {
                    Text("No reminders scheduled.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(pendingReminders, id: \.identifier) { reminder in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(reminder.content.title)
                                    .font(.headline)
                                Text(reminder.content.body)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                if let trigger = reminder.trigger as? UNCalendarNotificationTrigger,
                                   let date = trigger.nextTriggerDate() {
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.vertical, 5)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    cancelReminder(reminder)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Reminders")
            .onAppear {
                fetchReminders()
            }
        }
    }
    
    func fetchReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                pendingReminders = requests.sorted {
                    guard let t1 = $0.trigger as? UNCalendarNotificationTrigger,
                          let t2 = $1.trigger as? UNCalendarNotificationTrigger,
                          let d1 = t1.nextTriggerDate(),
                          let d2 = t2.nextTriggerDate() else { return false }
                    return d1 < d2
                }
            }
        }
    }
    
    func cancelReminder(_ reminder: UNNotificationRequest) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [reminder.identifier]
        )
        pendingReminders.removeAll { $0.identifier == reminder.identifier }
    }
}

#Preview {
    let center = UNUserNotificationCenter.current()
    
    // Sample reminder 1
    let content1 = UNMutableNotificationContent()
    content1.title = "Time to cook! 🍳"
    content1.body = "Don't forget to make Spaghetti Carbonara today."
    var components1 = DateComponents()
    components1.year = 2026
    components1.month = 3
    components1.day = 10
    components1.hour = 18
    components1.minute = 30
    let trigger1 = UNCalendarNotificationTrigger(dateMatching: components1, repeats: false)
    let request1 = UNNotificationRequest(identifier: "preview-1", content: content1, trigger: trigger1)
    
    // Sample reminder 2
    let content2 = UNMutableNotificationContent()
    content2.title = "Time to cook! 🍳"
    content2.body = "Don't forget to make Chicken Tikka Masala today."
    var components2 = DateComponents()
    components2.year = 2026
    components2.month = 3
    components2.day = 12
    components2.hour = 12
    components2.minute = 0
    let trigger2 = UNCalendarNotificationTrigger(dateMatching: components2, repeats: false)
    let request2 = UNNotificationRequest(identifier: "preview-2", content: content2, trigger: trigger2)
    
    center.add(request1)
    center.add(request2)
    
    return RemindersView()
}
