//
//  FixedEvent.swift
//  
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

public struct FixedEvent: Hashable {
    public let title: String
    public let timeDescription: String
    public let start: Date
    public let end: Date
    /// Sub-events that occur within this event (e.g. drive segments, breaks, sleep during travel).
    public let children: [FixedEvent]
    
    public init(
        title: String,
        timeDescription: String,
        start: Date,
        end: Date,
        children: [FixedEvent] = []
    ) {
        self.title = title
        self.timeDescription = timeDescription
        self.start = start
        self.end = end
        self.children = children
    }
}
