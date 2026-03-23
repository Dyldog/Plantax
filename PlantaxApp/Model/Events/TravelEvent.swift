//
//  TravelEvent.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation

public struct TravelEvent: Event {
    public let title: String
    public let line: Int
    public let mode: TravelMode
    public let origin: String
    public let destination: String
    /// Optional explicit start time (from an `@time` prefix).
    public let start: EventTime?
    /// Child activities that occur during the travel (schedule windows, recurring breaks, etc.).
    public let children: [TravelChild]
    /// The resolved driving duration from MapKit, set by `TravelDurationResolver`.
    public let resolvedDuration: TimeInterval?

    public var boundaries: (start: TimeInterval?, end: TimeInterval?) {
        (start?.offset, nil)
    }

    public var startTime: EventTime? { start }

    public func accept<Visitor>(visitor: Visitor) throws -> Visitor.Output where Visitor: EventVisitor {
        try visitor.visitTravelEvent(self)
    }
}
