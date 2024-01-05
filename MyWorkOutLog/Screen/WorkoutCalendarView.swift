//
//  CalendarView.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/04.
//

import SwiftUI
import SwiftData
import CalendarView

struct WorkoutCalendarView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone
    @Environment(\.modelContext) var modelContext
    @Query private var workoutHistories: [WorkoutHistory]
    @State private var selectedWorkoutHistory: WorkoutHistory?
    @State private var showWorkoutDetail = false
    
    @State private var dates: Set<DateComponents> = []
    @State private var selectedDates: DateComponents?
    
    var body: some View {
        NavigationStack{
            ScrollView{
                CalendarView(selection: $selectedDates)
                    .decorating(dates){ dateComponents in
                        return .customView {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .onChange(of: selectedDates){ oldValue, newValue in
                        if newValue != nil{
                            selectedWorkoutHistory = workoutHistories.first(where: {areDatesEqualInYearMonthDay(date1: $0.writeDate , date2: convertDateComponentsToDate(dateComponents: newValue) ?? Date())})
                        }
                    }
                    .onChange(of: selectedWorkoutHistory){ _, newValue in
                        self.selectedDates = nil
                        if newValue != nil{
                            self.showWorkoutDetail.toggle()
                        }
                    }
                
            }
            .onAppear{
                self.dates = Set(workoutHistories.map{convertDateToDateComponents(date:$0.writeDate )})
                self.selectedWorkoutHistory = nil
            }
           
            .navigationDestination(isPresented: $showWorkoutDetail){
                if let selected = selectedWorkoutHistory{
                    let workoutHistory = workoutHistories.filter{selected == $0}
                    WorkoutDayListView(workoutHistories: workoutHistory)
                    
                }
            }
        }
        
        //        .fullScreenCover(isPresented: $showWorkoutDetail){
        //            if let selected = selectedWorkoutHistory{
        //        let workoutHistory = workoutHistories.filter{selected == $0}
        //        WorkoutDayListView(workoutHistories: workoutHistory)
        
        //        }
    }
    
}
