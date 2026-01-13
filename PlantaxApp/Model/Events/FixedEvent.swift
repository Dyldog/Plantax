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
    
    public init(title: String, timeDescription: String, start: Date, end: Date) {
        self.title = title
        self.timeDescription = timeDescription
        self.start = start
        self.end = end
    }
}
