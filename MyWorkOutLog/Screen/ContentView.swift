//
//  ContentView.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/02.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workoutHistories: [WorkoutHistory]
    @State private var showAddWorkoutView: Bool = false
    @State private var showModifyWorkoutView: Bool = false
    @State private var selection: Tab = .list
    private let notificationManager = NotificationManager.instance
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var workoutDates: Set<Date> {
        return Set(workoutHistories.map{$0.writeDate }) // 현재 날짜와 하루 전 날짜
    }
    
    
    var body: some View {
        
        TabView(selection: $selection, content: {
            WorkoutListView()
                .tabItem{
                    Image(systemName: "list.bullet")
                    Text("리스트")
                }
                .id(Tab.list)
            WorkoutCalendarView()
                .tabItem{
                    Image(systemName: "calendar")
                    Text("달력")
                }
                .id(Tab.calendar)
            
            
            
            
        })
        .toolbar(.visible, for: .tabBar)
        .tint(.mint)
        .onAppear {
            if isWorkoutLoggedToday() {
                // 오늘 날짜에 대한 로그가 있으면, 로컬 알림 취소
                notificationManager.cancelNotification()
            } else {
                // 없으면, 로컬 알림 재설정
                notificationManager.scheduleNotification(trigger: .calendar)
            }
            UIApplication.shared.applicationIconBadgeNumber = 0 
        }
        
        
    }
    func isWorkoutLoggedToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return workoutHistories.contains(where: {
            Calendar.current.isDate($0.writeDate, inSameDayAs: today)
        })
    }
    
    
    
}

enum Tab{
    case calendar, list
}
//
//#Preview {
//    ContentView()
//        .modelContainer(for: WorkoutHistory.self, inMemory: true)
//}
