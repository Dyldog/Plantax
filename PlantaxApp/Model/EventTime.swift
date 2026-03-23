//
//  EventTime.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation

/// Pairs a time-of-day offset (seconds from midnight) with an optional date.
public struct EventTime {
    public let offset: TimeInterval
    public let date: EventDate?

    public init(offset: TimeInterval, date: EventDate? = nil) {
        self.offset = offset
        self.date = date
    }
}
