//
//  NewContentViewModel.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Combine
import Foundation
import SwiftUI

class NewContentViewModel: ObservableObject, EventCompiler {
    let events: [FixedEvent]

    /// IDs of parent rows whose children are currently expanded.
    /// Parents default to collapsed; toggling adds them here.
    var expandedParents: Set<Int> = []

    /// Monotonically increasing counter used to assign unique row IDs.
    private var nextId = 0

    var rows: [NewPlanRowModel] {
        nextId = 0
        return makeRows(from: events)
    }

    /// The ID of the first event row whose occurrence is `.present` (currently in progress).
    var currentEventId: Int? {
        rows.compactMap { row -> Int? in
            guard case .event(let model) = row, model.occurrence == .present else { return nil }
            return model.id
        }.first
    }

    init(events: [FixedEvent]) {
        self.events = events
    }

    func toggleCollapse(for rowId: Int) {
        objectWillChange.send()
        if expandedParents.contains(rowId) {
            expandedParents.remove(rowId)
        } else {
            expandedParents.insert(rowId)
        }
    }

    private func makeId() -> Int {
        defer { nextId += 1 }
        return nextId
    }

    // MARK: - Day Slicing

    /// A slice of an event that falls on a single calendar day.
    private struct DaySlice {
        let event: FixedEvent
        /// Effective start clamped to the beginning of this day (or the event's real start on the first day).
        let start: Date
        /// Effective end clamped to the end of this day (or the event's real end on the last day).
        let end: Date
        /// Whether this is a continuation from a previous day (i.e. not the first day).
        let isContinuation: Bool
        /// Children whose time range overlaps this day slice.
        let children: [FixedEvent]
    }

    /// Splits a single event into one `DaySlice` per calendar day it spans.
    private static func daySlices(for event: FixedEvent) -> [DaySlice] {
        let calendar = Calendar.current

        let startOfFirstDay = calendar.startOfDay(for: event.start)
        let startOfLastDay = calendar.startOfDay(for: event.end)

        // Fast path: event fits in a single day.
        if startOfFirstDay == startOfLastDay {
            return [
                DaySlice(
                    event: event,
                    start: event.start,
                    end: event.end,
                    isContinuation: false,
                    children: event.children
                )
            ]
        }

        var slices: [DaySlice] = []
        var currentDayStart = startOfFirstDay

        while currentDayStart <= startOfLastDay {
            guard let nextDayStart = calendar.date(byAdding: .day, value: 1, to: currentDayStart)
            else { break }

            let sliceStart = max(event.start, currentDayStart)
            let sliceEnd = min(event.end, nextDayStart)
            let isContinuation = currentDayStart != startOfFirstDay

            // Include children that overlap this day.
            let dayChildren = event.children.filter { child in
                child.start < sliceEnd && child.end > sliceStart
            }

            slices.append(
                DaySlice(
                    event: event,
                    start: sliceStart,
                    end: sliceEnd,
                    isContinuation: isContinuation,
                    children: dayChildren
                ))

            currentDayStart = nextDayStart
        }

        return slices
    }

    // MARK: - Row Building

    private func makeRows(from events: [FixedEvent]) -> [NewPlanRowModel] {
        // Flatten all events into per-day slices, preserving order.
        let allSlices = events.flatMap { Self.daySlices(for: $0) }

        var rows: [NewPlanRowModel] = []
        var lastSliceEnd: Date?
        var currentDateLabel: String?

        for slice in allSlices {
            let dateLabel = Self.dateHeaderLabel(for: slice.start)

            if dateLabel != currentDateLabel {
                currentDateLabel = dateLabel
                rows.append(.dateHeader(dateLabel))
                // Reset last slice end across day boundaries to avoid
                // showing a free-time gap that spans the header.
                lastSliceEnd = nil
            }

            if let lastEnd = lastSliceEnd, lastEnd < slice.start {
                rows.append(
                    .freeTime(
                        .init(
                            id: makeId(),
                            title: "Free",
                            timeDescription: "",
                            time: "\(lastEnd.description) -> \(slice.start.description)",
                            occurrence: occurrence(for: lastEnd, and: slice.start)
                        )))
            }

            let hasChildren = !slice.children.isEmpty
            let parentId = makeId()
            let isExpanded = expandedParents.contains(parentId)

            let title =
                slice.isContinuation
                ? "\(slice.event.title) (cont.)"
                : slice.event.title

            rows.append(
                .event(
                    .init(
                        id: parentId,
                        title: title,
                        time: "\(slice.start.description) -> \(slice.end.description)",
                        timeDescription: slice.isContinuation ? "" : slice.event.timeDescription,
                        occurrence: occurrence(for: slice.start, and: slice.end),
                        isChild: false,
                        hasChildren: hasChildren,
                        isContinuation: slice.isContinuation,
                        travelInfo: slice.event.travelInfo
                    )))

            if hasChildren, isExpanded {
                for child in slice.children {
                    // Clamp child times to the day slice window.
                    let childStart = max(child.start, slice.start)
                    let childEnd = min(child.end, slice.end)

                    rows.append(
                        .event(
                            .init(
                                id: makeId(),
                                title: child.title,
                                time: "\(childStart.description) -> \(childEnd.description)",
                                timeDescription: child.timeDescription,
                                occurrence: occurrence(for: childStart, and: childEnd),
                                isChild: true,
                                hasChildren: false
                            )))
                }
            }

            lastSliceEnd = slice.end
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
