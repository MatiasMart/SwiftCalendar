//
//  ContentView.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 15/02/2024.
//

import SwiftUI
import SwiftData
import WidgetKit

struct CalendarView: View {
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<Day> { $0.date > startDate && $0.date < endDate}, sort: \Day.date)
    var days: [Day]
    
    static var startDate: Date  { .now.startCalendarWithPrefixDays }
    static var endDate: Date  { .now.endOfMonth }
    
    let daysOfWeek: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    @State private var showAlert: Bool = false
    
    
    var body: some View {
        NavigationView {
            VStack{
                CalendarHeaderView()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days) {day in
                        if day.date.monthInt != Date().monthInt {
                            Text(" ")
                        } else {
                            Text(day.date.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(day.didStudy ? .orange : .secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(.orange.opacity(day.didStudy ? 0.3 : 0.0))
                                )
                                .onTapGesture {
                                    if day.date.dayInt <= Date().dayInt {
                                        day.didStudy.toggle()
                                        WidgetCenter.shared.reloadTimelines(ofKind: "SwiftCalendarWidget")

                                    } else {
                                        showAlert = true
                                    }
                                    
                                }
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Sure?"),
                        message: Text("Last time I checked, it was not yet possible to study in the future."),
                        dismissButton: .default(Text("Ok"))
                    )
                }
                Spacer()
            }
            .navigationTitle(Date().formatted(.dateTime.month(.wide)))
            .padding()
            .onAppear {
                if days.isEmpty {
                    createMonthDays(for: .now.startOfPreviousMonth)
                    createMonthDays(for: .now)
                } else if days.count < 10 {
                    createMonthDays(for: .now)
                }
            }
        }
        
    }
    
    func createMonthDays(for date: Date) {
        
        for dayOffset in 0..<date.numberOfDaysInMonth {
            
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: date.startOfMonth)!
            let newDay = Day(date: date, didStudy: false)
            context.insert(newDay)
            
        }
    }
}

#Preview {
    CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
