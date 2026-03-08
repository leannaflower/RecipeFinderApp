//
//  RecipeFinderAppApp.swift
//  RecipeFinderApp
//
//

import SwiftUI

@main
struct RecipeFinderAppApp: App {
    let notificationMgr = NotificationManager()
    /*
     NotificationMgr() is instantiated here which means its init() runs immediately; so the notification permission popup gets triggered as soon as the app launches.
     */
    let notificationDelegate = NotificationDelegate()
    
    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        // sets notificationDelegate as the delegate of UNUserNotificationCenter
        // Without setting this delegate, notifications wouldn't show up as banners while the app is open
        // By default iOS suppresses notifications if your app is in the foreground; the delegate overrides this behaviour
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationMgr) // every view inside ContentView can access it without you having to pass it manually through each layer
        }
    }
}

// this class allows notifications to show while the app is open
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,   // called by iOS right before it's about to deliver a notification while the app is in the foreground (By default iOS would suppress it)
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])    // thought by default iOS will suppress the notification while app is in the foreground, this func tells iOS "go ahead and show the banner and play the sound anyway."
    }
}
