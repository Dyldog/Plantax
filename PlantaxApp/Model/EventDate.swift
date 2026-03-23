//
//  EventDate.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation

public struct EventDate: Equatable {
    public let day: Int
    public let month: Int
    public let year: Int?

    public init(day: Int, month: Int, year: Int? = nil) {
        self.day = day
        self.month = month
        self.year = year
    }

    /// Resolves to a calendar date, using the current year when `year` is nil.
    public func resolve(using calendar: Calendar = .current) -> DateComponents {
        DateComponents(
            year: year ?? calendar.component(.year, from: .now),
            month: month,
            day: day
        )
    }
}
