//
//  NotificationManager.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/09.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let instance = NotificationManager()
    private init() {}
    
    
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("SUCCESS")
            }
        }
    }
    
    enum TriggerType: String {
        case time = "time"
        case calendar = "calendar"
        
        var trigger: UNNotificationTrigger {
            switch self {
            case .time:
                return UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            case .calendar:
                var dateComponents = DateComponents()
                dateComponents.hour = 22
                
                // 저녁 10시
                return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
            }
        }
    }
    func scheduleNotification(trigger: TriggerType) {
        let content = UNMutableNotificationContent()
        content.title = "운동 기록 알림".localized
        content.subtitle = "운동 기록을 잊지 마세요!".localized
        content.sound = .default
        content.badge = 1
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger.trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func resetApplicationIconBadgeNumber() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()  // 이미 배달된 모든 알림 제거
        center.getNotificationSettings { settings in
            if settings.badgeSetting != .disabled {
                // 배지 설정이 활성화되어 있을 경우, 배지 수를 0으로 설정
                let badgeResetContent = UNMutableNotificationContent()
                badgeResetContent.badge = NSNumber(value: 0)

                let badgeResetRequest = UNNotificationRequest(identifier: "badgeReset",
                                                              content: badgeResetContent,
                                                              trigger: nil)
                center.add(badgeResetRequest) { error in
                    if let error = error {
                        print("배지 리셋 알림 오류: \(error)")
                    }
                }
            }
        }
    }

}
