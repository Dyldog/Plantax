//
//  TravelRecurringChild.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation

/// A recurring child activity during travel (e.g. `%1h/10m Break`).
/// Triggers after every `interval` of accumulated driving time,
/// lasting for `duration`.
public struct TravelRecurringChild: TravelChild {
    /// Accumulated driving time between occurrences (e.g. 1 hour).
    public let interval: TimeInterval
    /// How long each occurrence lasts (e.g. 10 minutes).
    public let duration: TimeInterval
    public let title: String
}
