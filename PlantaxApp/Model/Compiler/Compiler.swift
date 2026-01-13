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
    
    let dayStart: Date = .now.startOfDay
    
    public init(rawEvents: [Event]) {
        self.rawEvents = rawEvents
    }
    
    public func fixEvents() throws -> [FixedEvent] {
        while rawEvents.isEmpty == false {
            let event = rawEvents.removeFirst()
//            do {
                try fixedEvents.append(event.accept(visitor: self))
//            } catch {
//                print(error)
//            }
        }
        
        return fixedEvents
    }
    
    public func visitClosedEvent(_ event: ClosedEvent) throws -> FixedEvent {
        let start = dayStart.addingTimeInterval(event.start)
        let end = dayStart.addingTimeInterval(event.end)
        
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
            let start = dayStart.addingTimeInterval(event.time)
            return FixedEvent(
                title: event.title,
                timeDescription: "From \(start.description)",
                start: start,
                end: dayStart.addingTimeInterval(nextStart)
            )
        case .end:
//            guard let previous = fixedEvents.last else {
//                throw error(event: event, message: "Event without start time must follow event with end time")
//            }
            let previousEnd = fixedEvents.last?.end ?? .now
            let end = dayStart.addingTimeInterval(event.time)
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
                end: dayStart.addingTimeInterval(60 * 60 * 24))
        case let .some(nextEvent):
            if let nextStart = nextEvent.boundaries.start {
                return FixedEvent(
                    title: event.title,
                    timeDescription: "",
                    start: previous.start,
                    end: dayStart.addingTimeInterval(nextStart)
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
