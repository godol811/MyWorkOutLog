//
//  MyWorkOutLogApp.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/02.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import UserNotifications

@main
struct MyWorkOutLogApp: App {
    
    @StateObject var permissionViewModel = PermissionViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.modelContext) private var modelContext
    @Query private var workoutHistories: [WorkoutHistory]
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutHistory.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: $permissionViewModel.permissionNotCompleted, content: {
                    PermissionView()
                        .environmentObject(permissionViewModel)
                })
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
                    }
            
        }
        .modelContainer(sharedModelContainer)
    }
}




class AppDelegate: NSObject, UIApplicationDelegate {
    // 기존의 application 메서드 유지
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       // Google Mobile Ads 초기화
       GADMobileAds.sharedInstance().start(completionHandler: nil)


       return true
    }

   
//    func resetApplicationIconBadgeNumber() {
//        let center = UNUserNotificationCenter.current()
//        center.removeAllDeliveredNotifications()  // 이미 배달된 모든 알림 제거
//        center.getNotificationSettings { settings in
//            if settings.badgeSetting != .disabled {
//                // 배지 설정이 활성화되어 있을 경우, 배지 수를 0으로 설정
//                let badgeResetContent = UNMutableNotificationContent()
//                badgeResetContent.badge = NSNumber(value: 0)
//
//                let badgeResetRequest = UNNotificationRequest(identifier: "badgeReset",
//                                                              content: badgeResetContent,
//                                                              trigger: nil)
//                center.add(badgeResetRequest) { error in
//                    if let error = error {
//                        print("배지 리셋 알림 오류: \(error)")
//                    }
//                }
//            }
//        }
//    }

}
