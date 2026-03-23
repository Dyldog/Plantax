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
    
    /// IDs of parent rows whose children are currently collapsed.
    var collapsedParents: Set<Int> = []
    
    /// Monotonically increasing counter used to assign unique row IDs.
    private var nextId = 0
    
    var rows: [NewPlanRowModel] {
        nextId = 0
        return makeRows(from: events)
    }
    
    init(events: [FixedEvent]) {
        self.events = events
    }
    
    func toggleCollapse(for rowId: Int) {
        objectWillChange.send()
        if collapsedParents.contains(rowId) {
            collapsedParents.remove(rowId)
        } else {
            collapsedParents.insert(rowId)
        }
    }
    
    private func makeId() -> Int {
        defer { nextId += 1 }
        return nextId
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
                    id: makeId(),
                    title: "Free",
                    timeDescription: "",
                    time: "\(lastEvent.end.description) -> \(event.start.description)",
                    occurrence: occurrence(for: lastEvent.end, and: event.start)
                )))
            }
            
            let hasChildren = !event.children.isEmpty
            let parentId = makeId()
            let isCollapsed = collapsedParents.contains(parentId)
            
            rows.append(.event(.init(
                id: parentId,
                title: event.title,
                time: "\(event.start.description) -> \(event.end.description)",
                timeDescription: event.timeDescription,
                occurrence: occurrence(for: event.start, and: event.end),
                isChild: false,
                hasChildren: hasChildren
            )))
            
            if hasChildren, !isCollapsed {
                for child in event.children {
                    rows.append(.event(.init(
                        id: makeId(),
                        title: child.title,
                        time: "\(child.start.description) -> \(child.end.description)",
                        timeDescription: child.timeDescription,
                        occurrence: occurrence(for: child.start, and: child.end),
                        isChild: true,
                        hasChildren: false
                    )))
                }
            }
            
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
