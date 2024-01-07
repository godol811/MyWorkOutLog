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
    }

    
    
}

enum Tab{
    case calendar, list
}

#Preview {
    ContentView()
        .modelContainer(for: WorkoutHistory.self, inMemory: true)
}
