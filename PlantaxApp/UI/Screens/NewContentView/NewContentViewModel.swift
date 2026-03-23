//
//  NewContentViewModel.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation
import SwiftUI
import Combine

class NewContentViewModel: ObservableObject, EventCompiler {
    let events: [FixedEvent]
    
    var rows: [NewPlanRowModel] {
        makeRows(from: events)
    }
    
    init(events: [FixedEvent]) {
        self.events = events
    }
    
    private func makeRows(from events: [FixedEvent]) -> [NewPlanRowModel] {
        var rows: [NewPlanRowModel] = []
        var lastEvent: FixedEvent?
        var currentDateLabel: String?
        
        for event in events {
            let dateLabel = Self.dateHeaderLabel(for: event.start)
            
            if dateLabel != currentDateLabel {
                currentDateLabel = dateLabel
                rows.append(.dateHeader(dateLabel))
            }
            
            if let lastEvent, lastEvent.end < event.start {
                rows.append(.freeTime(.init(
                    title: "Free",
                    timeDescription: "",
                    time: "\(lastEvent.end.description) -> \(event.start.description)",
                    occurrence: occurrence(for: lastEvent.end, and: event.start)
                )))
            }
            rows.append(.event(.init(
                title: event.title,
                time: "\(event.start.description) -> \(event.end.description)",
                timeDescription: event.timeDescription,
                occurrence: occurrence(for: event.start, and: event.end)
            )))
            lastEvent = event
        }
        
        return rows
    }
    
    private static let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static func dateHeaderLabel(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return headerFormatter.string(from: date)
        }
    }
    
    private func occurrence(for start: Date, and end: Date) -> NewContentRowModel.Occurrence {
        if end < .now {
            return .past
        } else if start < .now {
            return .present
        } else {
            return .future
        }
    }
}
