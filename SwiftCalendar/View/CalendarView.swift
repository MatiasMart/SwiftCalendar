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
    
    var currentCalendarDays: Int {
        days.filter { $0.date.monthInt == Date().monthInt }.count
    }
    
    var dayStudied: Int {
        days.filter { $0.date.monthInt == Date().monthInt }.filter { $0.didStudy}.count
    }
    
    @State private var showAlert: Bool = false
    
    @State private var isLiked: Bool = false
    
    let gradient = Gradient(colors: [.secondary, .orange, .mint])
    
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
                                        isLiked.toggle()
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
                Divider()
//                createCustomAnimationCustomButton(systemImage: "Swift", status: isLiked, activeTint: .pink, inActiveTint: .gray) {
//                    isLiked.toggle()
//                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    VStack {
                        Text("Total days in this month:")
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Text("\(currentCalendarDays)")
                            .fontWeight(.bold)
                            .foregroundStyle(.mint)
                    }
                    Gauge(value: Double(dayStudied), in: 1...Double(currentCalendarDays)) {
                        Image(systemName: "swift")
                    } currentValueLabel: {
                        Text("\(dayStudied)")
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(gradient)
                    VStack {
                        Text("Total days studied:")
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Text("\(dayStudied)")
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                    }
                }
                .padding()
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
    
    @ViewBuilder
    func createCustomAnimationCustomButton(systemImage: String, status: Bool, activeTint: Color, inActiveTint: Color, onTap: @escaping () -> ()) -> some View {
            Image(systemName: "swift")
                .font(.title2)
                .foregroundStyle(status ? activeTint : inActiveTint)
                .padding (.horizontal, 18)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                }
                .particleEffect(systemImage: "swift", font: .title2, status: status, activeTint: activeTint, inActiveTint: inActiveTint)
    }
    
    func createMonthDays(for date: Date) {
        
        for dayOffset in 0..<date.numberOfDaysInMonth {
            
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: date.startOfMonth)!
            let newDay = Day(date: date, didStudy: false)
            context.insert(newDay)
            
        }
    }
}

