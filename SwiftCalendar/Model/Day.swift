//
//  Day.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 20/02/2024.
//
//

import Foundation
import SwiftData


@Model class Day {
    var date: Date
    var didStudy: Bool
    
    
    init(date: Date, didStudy: Bool) {
        self.date = date
        self.didStudy = didStudy
    }
    
}
