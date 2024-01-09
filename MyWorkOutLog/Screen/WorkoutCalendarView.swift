//
//  CalendarView.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/04.
//

import SwiftUI
import SwiftData
import CalendarView
import GoogleMobileAds

struct WorkoutCalendarView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone
    @Environment(\.modelContext) var modelContext
    @Query private var workoutHistories: [WorkoutHistory]
    @State private var selectedWorkoutHistory: WorkoutHistory?
    @State private var showWorkoutDetail = false
    
    @State private var showAddWorkoutView: Bool = false
    
    @State private var dates: Set<DateComponents> = []
    @State private var selectedDates: DateComponents?
    

    
    var body: some View {
        NavigationStack{
            BannerView()
                .frame(height:60)
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
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $showAddWorkoutView, content: {
                WorkoutAddView(showWorkoutAddView: $showAddWorkoutView)
            })
            .onAppear{
                self.dates = Set(workoutHistories.map{convertDateToDateComponents(date:$0.writeDate )})
                self.selectedWorkoutHistory = nil
            }
            .navigationDestination(isPresented: $showWorkoutDetail){
                if let selected = selectedWorkoutHistory{
                    let workoutHistory = workoutHistories.filter{ areDatesEqualInYearMonthDay(date1: selected.writeDate , date2: $0.writeDate)}
                    WorkoutDayListView(workoutHistories: workoutHistory)
                        .onAppear{
                            debugPrint("AA \(workoutHistory)")
                        }
                }
            }
          
        }
        
        //        .fullScreenCover(isPresented: $showWorkoutDetail){
        //            if let selected = selectedWorkoutHistory{
        //        let workoutHistory = workoutHistories.filter{selected == $0}
        //        WorkoutDayListView(workoutHistories: workoutHistory)
        
        //        }
        
        
    }
    private func addItem() {
        withAnimation {
            showAddWorkoutView.toggle()
            print("\(showAddWorkoutView) ?????")
//            let newItem = WorkoutHistory(title: "타이틀", content: "컨텐츠", writeDate: Date(), conditions: .easy)
//            modelContext.insert(newItem)
        }
    }
}
