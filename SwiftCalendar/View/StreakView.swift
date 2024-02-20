//
//  StreakView.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 18/02/2024.
//

import SwiftUI
import SwiftData

struct StreakView: View {
    
    @Query(filter: #Predicate<Day> { $0.date > startDate && $0.date < endDate}, sort: \Day.date)
    var days: [Day]
    
    static var startDate: Date  { .now.startCalendarWithPrefixDays }
    static var endDate: Date  { .now.endOfMonth }
    
    @State private var streakValue = 0
    
    var body: some View {
        VStack{
            Text("\(streakValue)")
                .font(.system(size: 200, weight: .semibold, design: .rounded))
                .foregroundStyle(streakValue > 0 ? .orange : .pink)
            Text("Current Streak this Month")
                .font(.title2)
                .bold()
                .foregroundStyle(.secondary)
        }
        .offset(y: -50)
        .onAppear { streakValue = StreakCalculator().calculateStreakValue(for: days) }
    }
    
}

#Preview {
    StreakView()
}
