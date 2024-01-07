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

@main
struct MyWorkOutLogApp: App {
    
    @StateObject var permissionViewModel = PermissionViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
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
                    VStack {
                        Text("어서오세요 앱 시작하기전에 권한을 추가 해볼까요?")
                        Button(action: {
                            permissionViewModel.requestPermission()
                        }, label: {
                            RoundedRectangle(cornerRadius: 10)
                                .overlay(
                                    Text("권한 추가")
                                        .foregroundColor(.white)
                                )
                                .foregroundColor(.mint)
                        })
                        .frame(width: 100,height: 50)
                    }
                    .padding()
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
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

       GADMobileAds.sharedInstance().start(completionHandler: nil)

       return true
     }
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        requestDataPermission()
//    }
//
//    func requestDataPermission() {
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                switch status {
//                case .authorized:
//                    print("Authorized")
//                case .denied, .notDetermined, .restricted:
//                    print("Not Authorized")
//                @unknown default:
//                    print("UNKNOWN")
//                }
//            })
//        } else {
//            //you got permission to track, iOS 14 is not yet installed
//        }
//    }
    
}
