//
//  Persistence.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 15/02/2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let databaseName = "SwiftCalendar.sqlite"
    
    // We get the url that our default database is poiting to
    var oldStoreURL: URL {
        let directory =  FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appending(path: databaseName)
    }
    
    // We get the url of our new store so that the widget and the app can see the same information
    var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.co.matiasmart.SwiftCalendar")!
        return container.appending(path: databaseName)
    }

    static var preview: PersistenceController = {
        
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let startDate = Calendar.current.dateInterval(of: .month, for: .now)!.start
        for dayOffset in 0..<30 {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)
            newDay.didStudy = Bool.random()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        // We create our container
        container = NSPersistentCloudKitContainer(name: "SwiftCalendar")
        
        // If we are in a a preview point to the default path
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } 
         // IF nothing exist at the oldStoreURL then we point to the SharedStore
        else if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            print("🎅🏻 old store doesn't exist. Using new shared URL")
//            container.persistentStoreDescriptions.first?.url = sharedStoreURL
        }
        
        //Whereever we're pointing print that out
        print("🕸️ container URL = \(container.persistentStoreDescriptions.first!.url!)")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        //We call migrate
//        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Function to migrate stores
    func migrateStore(for container: NSPersistentContainer) {
        print("➡️ Went into migrateStore")
        // 1 We create a coordinator
        let coordinator = container.persistentStoreCoordinator
        
        // 2 We first check if we have an old store, if we do then we then will delete it
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return }
        print("🛡️ Old store deleted")
        
        // 3 We migrate the old stores to the new one
        do {
            let _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
            print("🏁 Migration Successful")

        } catch {
            fatalError("Unable to migrate to sharedStore")
        }
        
        // 4 After the migration we delete the old store
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
            print("🗑️ Old store deleted")

        } catch {
            print("Unable to delete old store")
        }
        
    }
}
