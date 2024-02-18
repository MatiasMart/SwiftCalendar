//
//  SwiftCalendarWidgetBundle.swift
//  SwiftCalendarWidget
//
//  Created by Matias Martinelli on 16/02/2024.
//

import WidgetKit
import SwiftUI

@main
struct SwiftCalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        SwiftCalendarWidget()
        SwiftCalendarWidgetLiveActivity()
    }
}
