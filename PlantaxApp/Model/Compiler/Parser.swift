//
//  Parser.swift
//  
//
//  Created by Dylan Elliott on 10/1/2026.
//

import Foundation

struct ParseError: LocalizedError {
    let token: Token
    let message: String
    
    var errorDescription: String? {
        if (token.type == TokenType.endOfFile) {
            "\(token.line) at end: \(message)"
        } else {
            "\(token.line) at '\(token.lexeme)' \(message)"
        }
    }
}

public class Parser {
    let tokens: [Token]
    
    private var current: Int = 0
    
    private var currentToken: Token { tokens[current] }
    
    private var events: [Event] = []
    
    public init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    public func parseEvents() throws -> [Event] {
        var events: [Event] = []
        
        while !isAtEnd {
//            do {
                events.append(try event())
//            } catch let error as ParseError {
                // TODO: Panic mode
//                print(error.localizedDescription)
//                synchronise()
//            } catch {
//                print(error)
//            }
        }
        
        return events
    }
    
    private func synchronise() {
        while [.newline, .endOfFile].contains(previous().type) == false {
            _ = advance()
        }
    }
    
    private func advance() -> Token {
        if !isAtEnd { current += 1 }
        return previous();
    }
    
    private var isAtEnd: Bool {
        return peek().type == .endOfFile;
    }
    
    private func peek() -> Token {
        return tokens[current]
    }
    
    private func previous() -> Token {
        return tokens[current - 1];
    }
    
    private func check(type: TokenType) -> Bool {
        guard !isAtEnd else { return false }
        return peek().type == type;
    }
    
    private func consume(type: TokenType, message: String) throws -> Token {
        if check(type: type) { return advance() }
        throw error(token: peek(), message: message)
    }
    
    private func match(types: TokenType...) -> Bool {
        for type in types {
            if (check(type: type)) {
                _ = advance();
                return true;
            }
        }
        
        return false;
    }
    
    // MARK: - Types
    
    private func event() throws -> Event {
        let eventLine = peek().line
        
        var start: EventTime?
        var end: EventTime?
        var duration: TimeInterval?
        
        if match(types: .at) {
            start = try time()
        }
        
        if match(types: .arrow) {
            end = try time()
        }
        
        if match(types: .hash) {
            duration = try self.duration()
        }

        // Travel events: DRIVE/RIDE/WALK origin -> destination
        if match(types: .drive, .ride, .walk) {
            guard end == nil, duration == nil else {
                throw error(token: previous(), message: "Travel cannot be combined with end time or duration")
            }
            let mode = travelMode(from: previous())
            let origin = try longString()
            _ = try consume(type: .arrow, message: "Expected '->' between origin and destination")
            let destination = try longString()
            let title = "\(mode.displayName) from \(origin) to \(destination)"

            if check(type: .newline) { _ = advance() }

            return TravelEvent(
                title: title,
                line: eventLine,
                mode: mode,
                origin: origin,
                destination: destination,
                start: start
            )
        }

        let title = try longString()
        
        let event: Event
        
        switch (start, end, duration) {
        case (nil, nil, nil):
            event = FreeEvent(title: title, line: eventLine)
        case let (.some(start), nil, nil):
            event = OpenEvent(title: title, line: eventLine, time: start, type: .start)
        case let (nil, .some(end), nil):
            event = OpenEvent(title: title, line: eventLine, time: end, type: .end)
        case let (.some(start), .some(end), nil):
            event = ClosedEvent(start: start, end: end, title: title, line: eventLine)
        case let (nil, .some(end), .some(duration)):
            let startTime = EventTime(
                offset: end.offset - duration,
                date: end.date
            )
            event = ClosedEvent(start: startTime, end: end, title: title, line: eventLine)
        case let (.some(start), nil, .some(duration)):
            let endTime = EventTime(
                offset: start.offset + duration,
                date: start.date
            )
            event = ClosedEvent(start: start, end: endTime, title: title, line: eventLine)
        case let (nil, nil, .some(duration)):
            event = DurationEvent(title: title, line: eventLine, duration: duration)
        case (.some, .some, .some):
            throw error(token: previous(), message: "Cannot set start, duration, and end")
        }
        
        if check(type: .newline) { _ = advance() }
        
        return event
    }
    
    private func time() throws -> EventTime {
        let date = try optionalDate()
        
        let hours = try number()
        var minutes: Int? = 0
        
        if match(types: .colon) {
            minutes = try number()
        }
        
        let meridiem = try meridiem()
        let offset = TimeInterval.interval(forHour: hours, minutes: minutes, and: meridiem)
        return EventTime(offset: offset, date: date)
    }
    
    /// Parses an optional date in `day/month` or `day/month/year` format.
    private func optionalDate() throws -> EventDate? {
        guard check(type: .number) else { return nil }
        
        // Peek ahead to see if a slash follows the number — if not, it's a time, not a date.
        guard current + 1 < tokens.count, tokens[current + 1].type == .slash else {
            return nil
        }
        
        let day = try number()
        _ = try consume(type: .slash, message: "Expected '/' in date")
        let month = try number()
        
        var year: Int?
        if match(types: .slash) {
            year = try number()
        }
        
        return EventDate(day: day, month: month, year: year)
    }
    
    private func duration() throws -> TimeInterval {
        var total: TimeInterval = 0

        let value = TimeInterval(try number())

        guard match(types: .minutes, .hours) else {
            throw error(token: previous(), message: "Duration must be followed by 'm' or 'h'")
        }

        let unit = previous()
        switch unit.type {
        case .minutes: total += value * 60
        case .hours:   total += value * 60 * 60
        default: break
        }

        // Support compound durations like `3h30m`
        if unit.type == .hours, check(type: .number) {
            let minuteValue = TimeInterval(try number())
            guard match(types: .minutes) else {
                throw error(token: previous(), message: "Expected 'm' after minutes in compound duration")
            }
            total += minuteValue * 60
        }

        return total
    }
    
    private func longString() throws -> String {
        var title: [String] = [try string()]
        
        while check(type: .word) {
            title.append(try string())
        }
        
        return title.joined(separator: " ")
    }
    
    private func string() throws -> String {
        try consume(type: .word, message: "Expected string").lexeme
    }
    
    private func number() throws -> Int {
        let token = try consume(type: .number, message: "Expected number")
        guard let value = token.literal as? Int else {
            throw error(token: token, message: "Number token did not contain int")
        }
        return value
    }
    
    private func meridiem() throws -> Meridiem {
        if match(types: .am, .pm) {
            let token = previous()
            
            switch token.type {
            case .am: return .am
            case .pm: return .pm
            default: break
            }
        }
        
        throw error(token: peek(), message: "Expected 'am' or 'pm'")
    }
    
    private func travelMode(from token: Token) -> TravelMode {
        switch token.type {
        case .drive: .drive
        case .ride: .ride
        case .walk: .walk
        default: .drive
        }
    }

    // MARK: - Error Handling
    
    private func error(token: Token, message: String) -> ParseError {
        .init(token: token, message: message)
    }
}

extension TimeInterval {
    private static var anHour: TimeInterval {
        60 * .aMinute
    }
    
    private static var aMinute: TimeInterval {
        60
    }
    
    static func interval(forHour hour: Int, minutes: Int?, and meridiem: Meridiem) -> TimeInterval {
        TimeInterval(hour % 12) * .anHour + TimeInterval(minutes ?? 0) * .aMinute + offset(for: meridiem, at: hour)
    }
    
    private static func offset(for meridiem: Meridiem, at hour: Int) -> TimeInterval {
        switch meridiem {
        case .am: hour == 12 ? TimeInterval(24) * .anHour : 0 // TODO: Fix for 12am at the start of the day
        case .pm: TimeInterval(12) * .anHour
        }
    }
}
