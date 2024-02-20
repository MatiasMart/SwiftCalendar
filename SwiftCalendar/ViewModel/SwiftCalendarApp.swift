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
    static let databaseName = "SwiftCalendar.sqlite"
    
    // We get the url of our new store so that the widget and the app can see the same information
    static var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.co.matiasmart.SwiftCalendar")!
        return container.appending(path: databaseName)
    }
    
    let container: ModelContainer = {
        let config = ModelConfiguration(url: sharedStoreURL)
        return try! ModelContainer(for: Day.self, configurations: config)
    }()
    
    
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
            .modelContainer(container)
            .onOpenURL { url in
                print(url.absoluteString)
                selectedTab = url.absoluteString == "calendar" ? 0 : 1
                print(selectedTab)
            }
        }
    }
}
