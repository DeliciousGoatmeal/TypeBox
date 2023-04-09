//
//  notifcationSender.swift
//  TypeBox
//
//  Created by Goat on 4/4/23.
//

import Foundation
import UserNotifications

func sendNotification() {
    let center = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = "Copied to Clipboard"
    content.body = "The directory path has been copied to the clipboard."
    content.sound = UNNotificationSound.default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    center.add(request) { error in
        if let error = error {
            print("Failed to add notification request: \(error)")
        } else {
            print("Notification request added successfully")
        }
    }
}
