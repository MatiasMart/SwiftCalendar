//
//  StreakCalculator.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 20/02/2024.
//

import Foundation
import SwiftUI

struct StreakCalculator {
    
    func calculateStreakValue(for days: FetchedResults<Day>) -> Int {
        
        guard !days.isEmpty else {return 0}
        
        let nonFutureDays = days.filter { $0.date!.dayInt <= Date().dayInt }
        
        var streakCount = 0
        
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else {
                // Give the day of today in advance so it does not break the streak at the beginning of the day
                if day.date!.dayInt != Date().dayInt {
                    break
                }
            }
        }
        return streakCount
    }
}
