//
//  CalenderHeaderView.swift
//  SwiftCalendar
//
//  Created by Matias Martinelli on 19/02/2024.
//

import SwiftUI

struct CalendarHeaderView: View {
    
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    var font: Font = .body
    
    var body: some View {
        HStack{
            ForEach (daysOfWeek, id: \.self) {daysOfWeek in
                Text(daysOfWeek)
                    .font(font)
                    .fontWeight(.black)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    CalendarHeaderView()
}
