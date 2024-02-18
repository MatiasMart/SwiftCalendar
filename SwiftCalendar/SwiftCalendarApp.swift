//
//  SwiftCalendarApp.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 15/02/2024.
//

import SwiftUI

@main
struct SwiftCalendarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                CalendarView()
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                StreakView()
                    .tabItem { Label("Streak", systemImage: "flame.fill") }
            }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
