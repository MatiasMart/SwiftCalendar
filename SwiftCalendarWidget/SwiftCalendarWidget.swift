//
//  SwiftCalendarWidget.swift
//  SwiftCalendarWidget
//
//  Created by Matias Martinelli on 16/02/2024.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

struct Provider: TimelineProvider {
    
    let container = Persistence().container
    
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), days: [])
    }
    
    @MainActor func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        
        //We use the request to fetch the days
            let entry = CalendarEntry(date: Date(), days: fetchDays())
            completion(entry)

    }
    
    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        //We use the request to fetch the days
            let entry = CalendarEntry(date: Date(), days: fetchDays())
            //                                        We update at the end of the day to check for the streak
            let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))
            completion(timeline)
    }
    
    @MainActor func fetchDays() -> [Day] {
        
        let startDate = Date().startCalendarWithPrefixDays
        let endDate = Date().endOfMonth
        
        let predicate = #Predicate<Day> { $0.date > startDate && $0.date < endDate}
        let descriptor = FetchDescriptor<Day>(predicate: predicate, sortBy: [.init(\.date)])
        
        return try! container.mainContext.fetch(descriptor)
        
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let days: [Day]
}

struct SwiftCalendarWidgetEntryView : View {
    // First we introduce the widget family
    @Environment(\.widgetFamily) var family
    
    var entry: CalendarEntry
    
    var today: Day {
        entry.days.filter  { Calendar.current.isDate($0.date, inSameDayAs: .now) }.first ?? .init(date: .distantPast, didStudy: false)
    }
    
    var body: some View {
        switch family {
        case .systemMedium:
            MediumCalendarView(today: today,
                               entry: entry,
                               streakValue: calculateStreakValue())
        case .accessoryCircular:
            LockScreenCircular(entry: entry)
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
        case .accessoryInline:
            Label("Streak - \(calculateStreakValue()) days", systemImage: "swift")
        case .systemSmall, .systemLarge, .systemExtraLarge:
            EmptyView()
        @unknown default:
            EmptyView()
        }

    }
    
    func calculateStreakValue() -> Int {
        
        guard !entry.days.isEmpty else {return 0}
        
        let nonFutureDays = entry.days.filter { $0.date.dayInt <= Date().dayInt }
        
        var streakCount = 0
        
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else {
                // Give the day of today in advance so it does not break the streak at the beginning of the day
                if day.date.dayInt != Date().dayInt {
                    break
                }
            }
        }
        return streakCount
    }
}



struct SwiftCalendarWidget: Widget {
    let kind: String = "SwiftCalendarWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SwiftCalendarWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SwiftCalendarWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Swift Study Calendar")
        .description("Track day you study Swift with Streaks")
        .supportedFamilies([.systemMedium,
                            .accessoryCircular,
                            .accessoryRectangular,
                            .accessoryInline])
    }
}

#Preview(as: .accessoryCircular) {
    SwiftCalendarWidget()
} timeline: {
    CalendarEntry(date: .now, days: [])
    CalendarEntry(date: .now, days: [])
}

//MARK: - UI Components for widget sises

private struct MediumCalendarView: View {
    var today: Day
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    var entry: CalendarEntry
    var streakValue: Int
    var body: some View {
        
        HStack {
            VStack{
                Link(destination: URL(string: "streak")!) {
                    VStack{
                        Text("\(streakValue)")
                            .font(.system(size: 70, design: .rounded))
                            .bold()
                            .foregroundStyle(.orange)
                            .contentTransition(.numericText())
                        
                        Text("day streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Button(today.didStudy ? "Studied" : "Study",
                       systemImage: today.didStudy ? "checkmark.circle" : "book",
                       intent: ToggleStudyIntent(date: today.date))
                    .font(.caption)
                    .tint(today.didStudy ? .mint : .orange)
                    .controlSize(.small)
            }
            .frame(width: 90)
            
            Link(destination: URL(string: "calendar")!) {
                VStack {
                    CalendarHeaderView(font: .caption)
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(entry.days) { day in
                            if day.date.monthInt != Date().monthInt {
                                Text(" ")
                            } else {
                                Text(day.date.formatted(.dateTime.day()))
                                    .font(.caption2)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(day.didStudy ? .orange : .secondary)
                                    .background(
                                        Circle()
                                            .foregroundStyle(.orange.opacity(day.didStudy ? 0.4 : 0.0))
                                            .scaleEffect(1.4)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.leading, 6)
        }
        .padding()
    }
}

private struct LockScreenCircular: View {
    var entry: CalendarEntry
    
    var currentCalendarDays: Int {
        entry.days.filter { $0.date.monthInt == Date().monthInt }.count
    }
    
    var dayStudied: Int {
        entry.days.filter { $0.date.monthInt == Date().monthInt }.filter { $0.didStudy}.count
    }
    
    var body: some View {
        Gauge(value: Double(dayStudied), in: 1...Double(currentCalendarDays)) {
            Image(systemName: "swift")
        } currentValueLabel: {
            Text("\(dayStudied)")
        }
        .gaugeStyle(.accessoryCircular)
    }
}

private struct LockScreenRectangularView: View {
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    var entry: CalendarEntry
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(entry.days) { day in
                if day.date.monthInt != Date().monthInt {
                    Text(" ")
                        .font(.system(size: 7))
                } else {
                    if day.didStudy {
                        Image(systemName: "swift")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 7, height: 7)
                    } else {
                        Text(day.date.formatted(.dateTime.day()))
                            .font(.system(size: 7))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
    }
}
