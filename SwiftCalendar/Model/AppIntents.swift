//
//  AppIntents.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 21/02/2024.
//
//                                           * * * * An AppIntent it's a small piece of functionality from out App that we expose to the system * * * *

import Foundation
import AppIntents
import SwiftData

struct ToggleStudyIntent: AppIntent {

    static var title: LocalizedStringResource = "ToggleStudy"
    
    @Parameter(title: "Date")
    var date: Date

    init(date: Date) {
        self.date = date
    }
    
    init() { }
    
    func perform() async throws -> some IntentResult {
        let context = ModelContext(Persistence().container)
        let predicate = #Predicate<Day> { $0.date == date }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        guard let day = try! context.fetch(descriptor).first else { return .result()}
        day.didStudy.toggle()
        
        try! context.save()
        
        return .result()
    }
    
}
