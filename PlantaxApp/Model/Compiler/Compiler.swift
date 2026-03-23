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
    
    /// Resolves an `EventTime` to an absolute `Date` without mutating
    /// `currentBaseDate`. Used to peek at future events.
    private func peekResolve(_ eventTime: EventTime) -> Date {
        var baseDate = currentBaseDate
        if let eventDate = eventTime.date {
            let components = eventDate.resolve(using: calendar)
            if let explicit = calendar.date(from: components) {
                baseDate = explicit
            }
        }
        return baseDate.addingTimeInterval(eventTime.offset)
    }
    
    public func visitOpenEvent(_ event: OpenEvent) throws -> FixedEvent {
        switch event.type {
        case .start:
            guard let next = rawEvents.first, let nextStartTime = next.startTime else {
                throw error(event: event, message: "Event without end time must be followed by event with start time")
            }
            let start = resolve(event.time)
            let end = peekResolve(nextStartTime)
            return FixedEvent(
                title: event.title,
                timeDescription: "From \(start.description)",
                start: start,
                end: end
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
            if let nextStartTime = nextEvent.startTime {
                return FixedEvent(
                    title: event.title,
                    timeDescription: "",
                    start: previous.start,
                    end: peekResolve(nextStartTime)
                )
            } else {
                throw CompilerError(event: event, message: "Event without end time cannot precede event without start time")
            }
        }
    }
    
    public func visitTravelEvent(_ event: TravelEvent) throws -> FixedEvent {
        let start: Date
        if let eventStart = event.start {
            start = resolve(eventStart)
        } else if let previous = fixedEvents.last {
            start = previous.end
        } else {
            throw error(event: event, message: "Travel event without start time must follow an event with an end time")
        }

        guard let driveDuration = event.resolvedDuration else {
            // Unresolved — use a placeholder.
            let placeholderDuration: TimeInterval = 30 * 60
            return FixedEvent(
                title: event.title,
                timeDescription: "Travel (~30 min placeholder)",
                start: start,
                end: start.addingTimeInterval(placeholderDuration)
            )
        }

        guard !event.children.isEmpty else {
            // No children — single travel event.
            return FixedEvent(
                title: event.title,
                timeDescription: "Travel (\(driveDuration.durationString))",
                start: start,
                end: start.addingTimeInterval(driveDuration)
            )
        }

        // Expand the schedule with children.
        let expanded = expandTravelSchedule(
            driveDuration: driveDuration,
            startDate: start,
            children: event.children,
            travelTitle: event.title
        )

        // Append all but the last event; return the last so the
        // main loop can add it and track the end time.
        for intermediate in expanded.dropLast() {
            advanceBaseDate(to: intermediate.end)
            fixedEvents.append(intermediate)
        }

        return expanded.last ?? FixedEvent(
            title: event.title,
            timeDescription: "Travel",
            start: start,
            end: start.addingTimeInterval(driveDuration)
        )
    }

    // MARK: - Travel Schedule Expansion

    /// Simulates the journey, interleaving driving segments with child
    /// activities (schedule windows and recurring breaks).
    ///
    /// Children are checked in declaration order — higher-listed children
    /// take precedence when they overlap.
    private func expandTravelSchedule(
        driveDuration: TimeInterval,
        startDate: Date,
        children: [TravelChild],
        travelTitle: String
    ) -> [FixedEvent] {
        var events: [FixedEvent] = []
        var currentTime = startDate
        var remainingDriveTime = driveDuration
        var accumulatedDriveTime: TimeInterval = 0

        // Safety limit to avoid infinite loops from bad input.
        var iterations = 0
        let maxIterations = 10_000

        while remainingDriveTime > 1, iterations < maxIterations {
            iterations += 1

            // 1. Check if we're inside a schedule child's window (by priority).
            if let (child, windowEnd) = firstActiveScheduleChild(at: currentTime, children: children) {
                events.append(FixedEvent(
                    title: child.title,
                    timeDescription: "\(child.title)",
                    start: currentTime,
                    end: windowEnd
                ))
                currentTime = windowEnd
                accumulatedDriveTime = 0
                continue
            }

            // 2. Check if a recurring break is due.
            if let child = firstDueRecurringChild(accumulated: accumulatedDriveTime, children: children) {
                let breakEnd = currentTime.addingTimeInterval(child.duration)
                events.append(FixedEvent(
                    title: child.title,
                    timeDescription: "For \(child.duration.durationString)",
                    start: currentTime,
                    end: breakEnd
                ))
                currentTime = breakEnd
                accumulatedDriveTime = 0
                continue
            }

            // 3. Drive until the next interruption or until done.
            let segment = nextDriveSegment(
                from: currentTime,
                accumulated: accumulatedDriveTime,
                remaining: remainingDriveTime,
                children: children
            )

            let segmentEnd = currentTime.addingTimeInterval(segment)
            events.append(FixedEvent(
                title: travelTitle,
                timeDescription: "",
                start: currentTime,
                end: segmentEnd
            ))

            remainingDriveTime -= segment
            accumulatedDriveTime += segment
            currentTime = segmentEnd
        }

        return events
    }

    /// Returns the first schedule child whose clock-time window includes `time`,
    /// together with the absolute `Date` when that window ends.
    private func firstActiveScheduleChild(
        at time: Date,
        children: [TravelChild]
    ) -> (TravelScheduleChild, Date)? {
        let timeOfDay = timeOfDayOffset(for: time)

        for child in children {
            guard let schedule = child as? TravelScheduleChild else { continue }
            let startOffset = schedule.start.offset
            let endOffset = schedule.end.offset

            let isActive: Bool
            if startOffset < endOffset {
                isActive = timeOfDay >= startOffset && timeOfDay < endOffset
            } else {
                // Crosses midnight (e.g. 11 pm → 8 am).
                isActive = timeOfDay >= startOffset || timeOfDay < endOffset
            }

            if isActive {
                let windowEnd = dateForNextOccurrence(of: endOffset, after: time)
                return (schedule, windowEnd)
            }
        }
        return nil
    }

    /// Returns the first recurring child whose interval has been met.
    private func firstDueRecurringChild(
        accumulated: TimeInterval,
        children: [TravelChild]
    ) -> TravelRecurringChild? {
        for child in children {
            guard let recurring = child as? TravelRecurringChild else { continue }
            if accumulated >= recurring.interval {
                return recurring
            }
        }
        return nil
    }

    /// Calculates the longest uninterrupted drive segment from `time`.
    private func nextDriveSegment(
        from time: Date,
        accumulated: TimeInterval,
        remaining: TimeInterval,
        children: [TravelChild]
    ) -> TimeInterval {
        var minSegment = remaining

        for child in children {
            if let schedule = child as? TravelScheduleChild {
                let until = timeUntilNextOccurrence(of: schedule.start.offset, from: time)
                if until > 0 {
                    minSegment = min(minSegment, until)
                }
            } else if let recurring = child as? TravelRecurringChild {
                let until = recurring.interval - accumulated
                if until > 0 {
                    minSegment = min(minSegment, until)
                }
            }
        }

        return max(minSegment, 0)
    }

    // MARK: - Time-of-Day Helpers

    private func timeOfDayOffset(for date: Date) -> TimeInterval {
        let startOfDay = calendar.startOfDay(for: date)
        return date.timeIntervalSince(startOfDay)
    }

    /// Returns the next absolute `Date` at which the given time-of-day
    /// offset occurs (today if still in the future, otherwise tomorrow).
    private func dateForNextOccurrence(of offset: TimeInterval, after date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let candidate = startOfDay.addingTimeInterval(offset)
        return candidate > date ? candidate : candidate.addingTimeInterval(24 * 60 * 60)
    }

    private func timeUntilNextOccurrence(of offset: TimeInterval, from date: Date) -> TimeInterval {
        dateForNextOccurrence(of: offset, after: date).timeIntervalSince(date)
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
