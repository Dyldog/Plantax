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
//        events.map { event in
//            .init(
//                title: event.title,
//                time: "\(event.start.description) -> \(event.end.description)",
//                timeDescription: event.timeDescription,
//                occurrence: occurrence(for: event.start, and: event.end)
//            )
//        }
        
        var rows: [NewPlanRowModel] = []
        var lastEvent: FixedEvent?
        
        for event in events {
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
