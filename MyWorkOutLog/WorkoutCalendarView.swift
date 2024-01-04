//
//  CalendarView.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/04.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone
    @Environment(\.modelContext) private var modelContext
    @Query private var workoutHistories: [WorkoutHistory]

    var bounds: Range<Date> {
        let start = calendar.date(from: DateComponents(
            timeZone: timeZone, year: 2022, month: 6, day: 6))!
        let end = calendar.date(from: DateComponents(
            timeZone: timeZone, year: 2022, month: 6, day: 16))!
        return start ..< end
    }
    @State private var dates: Set<DateComponents> = []
    
    var body: some View {
        MultiDatePicker("Dates Available", selection: $dates)
            .environment(\.locale, Locale.init(identifier: "kr"))
            .environment(
                \.calendar, Calendar.init(identifier: .gregorian))
            .environment(\.timeZone, TimeZone(abbreviation: "KST")!)
            .onAppear{
                self.dates = Set(workoutHistories.map{convertDateToDateComponents(date: $0.writeDate)})
            }
    }
}

