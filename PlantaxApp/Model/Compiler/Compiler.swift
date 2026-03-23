//
//  Compiler.swift
//  
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

struct CompilerError: LocalizedError {
    let event: Event
    let message: String
    
    var errorDescription: String? {
        message
    }
}

public class Compiler: EventVisitor {
    var rawEvents: [Event]
    var fixedEvents: [FixedEvent] = []
    
    private let calendar: Calendar = .current
    
    /// The running base date used for events that don't specify their own date.
    /// Advances automatically when an explicit date is set or when an event's
    /// end time crosses midnight.
    private var currentBaseDate: Date
    
    public init(rawEvents: [Event]) {
        self.rawEvents = rawEvents
        self.currentBaseDate = Date.now.startOfDay
    }
    
    public func fixEvents() throws -> [FixedEvent] {
        while rawEvents.isEmpty == false {
            let event = rawEvents.removeFirst()
//            do {
                let fixed = try event.accept(visitor: self)
                advanceBaseDate(to: fixed.end)
                fixedEvents.append(fixed)
//            } catch {
//                print(error)
//            }
        }
        
        return fixedEvents
    }
    
    /// Resolves an `EventTime` to an absolute `Date`.
    /// When the event carries an explicit date, the base date is updated to
    /// that date so subsequent events inherit it.
    private func resolve(_ eventTime: EventTime) -> Date {
        if let eventDate = eventTime.date {
            let components = eventDate.resolve(using: calendar)
            if let explicit = calendar.date(from: components) {
                currentBaseDate = explicit
            }
        }
        return currentBaseDate.addingTimeInterval(eventTime.offset)
    }
    
    /// If `date` falls on a later calendar day than `currentBaseDate`, advance
    /// the base to the start of that day so following events land on the
    /// correct date.
    private func advanceBaseDate(to date: Date) {
        let endOfBaseDay = calendar.startOfDay(for: currentBaseDate).addingTimeInterval(60 * 60 * 24)
        if date >= endOfBaseDay {
            currentBaseDate = calendar.startOfDay(for: date)
        }
    }
    
    public func visitClosedEvent(_ event: ClosedEvent) throws -> FixedEvent {
        let start = resolve(event.start)
        let end = resolve(event.end)
        
        return FixedEvent(
            title: event.title,
            timeDescription: "From \(start.description) to \(end.description)",
            start: start,
            end: end
        )
    }
    
    public func visitDurationEvent(_ event: DurationEvent) throws -> FixedEvent {
        guard let previous = fixedEvents.last else {
            throw error(event: event, message: "Event without start time must follow event with end time")
        }
        
        return FixedEvent(
            title: event.title,
            timeDescription: "For \(event.duration.durationString)",
            start: previous.end,
            end: previous.end.addingTimeInterval(event.duration)
        )
    }
    
    public func visitOpenEvent(_ event: OpenEvent) throws -> FixedEvent {
        switch event.type {
        case .start:
            guard let next = rawEvents.first, let nextStart = next.boundaries.start else {
                throw error(event: event, message: "Event without end time must be followed by event with start time")
            }
            let start = resolve(event.time)
            return FixedEvent(
                title: event.title,
                timeDescription: "From \(start.description)",
                start: start,
                end: currentBaseDate.addingTimeInterval(nextStart)
            )
        case .end:
            let previousEnd = fixedEvents.last?.end ?? .now
            let end = resolve(event.time)
            return FixedEvent(
                title: event.title,
                timeDescription: "Until \(end.description)",
                start: previousEnd,
                end: end
            )
        }
    }
    
    public func visitFreeEvent(_ event: FreeEvent) throws -> FixedEvent {
        guard let previous = fixedEvents.last else {
            throw error(event: event, message: "Event without start time must follow event with end time")
        }
        
        switch rawEvents.first {
        case nil:
            return FixedEvent(
                title: event.title,
                timeDescription: "",
                start: previous.end,
                end: currentBaseDate.addingTimeInterval(60 * 60 * 24))
        case let .some(nextEvent):
            if let nextStart = nextEvent.boundaries.start {
                return FixedEvent(
                    title: event.title,
                    timeDescription: "",
                    start: previous.start,
                    end: currentBaseDate.addingTimeInterval(nextStart)
                )
            } else {
                throw CompilerError(event: event, message: "Event without end time cannot precede event without start time")
            }
        }
    }
    
    // MARK: - Error Handling
    
    private func error(event: Event, message: String) -> CompilerError {
        .init(event: event, message: message)
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: .now)
    }
    
    static let descriptionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var description: String {
        Self.descriptionFormatter.string(from: self)
    }
}

extension TimeInterval {
    static let durationStringFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full // e.g., "2 hours, 6 minutes"
        formatter.zeroFormattingBehavior = .pad // pads zero values if needed in positional style

        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll

        return formatter
    }()
    
    var durationString: String {
        Self.durationStringFormatter.string(from: self)!
    }
}
