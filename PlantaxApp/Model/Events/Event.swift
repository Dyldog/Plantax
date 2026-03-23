//
//  Event.swift
//  
//
//  Created by Dylan Elliott on 10/1/2026.
//

import Foundation

public protocol Event {
    var title: String { get }
    
    /// The source line where this event was defined.
    var line: Int { get }
    
    /// Child activities that occur within this event (schedule windows, recurring breaks, etc.).
    var children: [EventChild] { get }
    
    func accept<Visitor: EventVisitor>(visitor: Visitor) throws -> Visitor.Output
    
    var boundaries: (start: TimeInterval?, end: TimeInterval?) { get }
    
    /// The full start time (including any date) for this event, if it has one.
    var startTime: EventTime? { get }
}

extension Event {
    var hasStart: Bool { boundaries.start != nil }
    var hasEnd: Bool { boundaries.end != nil }
}

public protocol EventVisitor {
    associatedtype Output
    func visitClosedEvent(_ event: ClosedEvent) throws -> Output
    func visitDurationEvent(_ event: DurationEvent) throws -> Output
    func visitOpenEvent(_ event: OpenEvent) throws -> Output
    func visitFreeEvent(_ event: FreeEvent) throws -> Output
    func visitTravelEvent(_ event: TravelEvent) throws -> Output
}
