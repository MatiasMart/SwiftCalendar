//
//  Persistance.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 20/02/2024.
//

import Foundation
import SwiftData


struct Persistance {
    
    // We get the url of our new store so that the widget and the app can see the same information
    static var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.co.matiasmart.SwiftCalendar")!
        return container.appending(path: "SwiftCalendar.sqlite")
    }
    
    let container: ModelContainer = {
        let config = ModelConfiguration(url: sharedStoreURL)
        return try! ModelContainer(for: Day.self, configurations: config)
    }()
    
}
