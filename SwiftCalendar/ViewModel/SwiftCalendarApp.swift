//
//  SwiftCalendarApp.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 15/02/2024.
//

import SwiftUI
import SwiftData

@main
struct SwiftCalendarApp: App {
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab){
                CalendarView()
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                    .tag(0)
                StreakView()
                    .tabItem { Label("Streak", systemImage: "flame.fill") }
                    .tag(1)
            }
            .modelContainer(Persistance().container)
            .onOpenURL { url in
                print(url.absoluteString)
                selectedTab = url.absoluteString == "calendar" ? 0 : 1
                print(selectedTab)
            }
        }
    }
}
