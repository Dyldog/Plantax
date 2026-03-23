//
//  ScheduleChild.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation

/// A clock-time-based child activity (e.g. `@11pm->8am Sleep`).
/// Activates whenever the wall-clock falls within its time window.
public struct ScheduleChild: EventChild {
    /// Time-of-day offset (seconds from midnight) when this activity starts.
    public let start: EventTime
    /// Time-of-day offset (seconds from midnight) when this activity ends.
    public let end: EventTime
    public let title: String

    /// Whether the window crosses midnight (e.g. 11pm → 8am).
    public var crossesMidnight: Bool {
        start.offset >= end.offset
    }
}
