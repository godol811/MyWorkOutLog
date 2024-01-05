//
//  MyWorkOutLogApp.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/02.
//

import SwiftUI
import SwiftData

@main
struct MyWorkOutLogApp: App {
    
    @StateObject var permissionViewModel = PermissionViewModel()
    
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
            
        }
        .modelContainer(sharedModelContainer)
    }
}
