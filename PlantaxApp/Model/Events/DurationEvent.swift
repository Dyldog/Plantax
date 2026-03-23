//
//  DurationEvent.swift
//  
//
//  Created by Dylan Elliott on 10/1/2026.
//

import Foundation

public struct DurationEvent: Event {
    public let title: String
    public let line: Int
    public let duration: TimeInterval
    
    public var boundaries: (start: TimeInterval?, end: TimeInterval?) { (nil, nil) }
    public var startTime: EventTime? { nil }
    
    public init(title: String, line: Int, duration: TimeInterval) {
        self.title = title
        self.line = line
        self.duration = duration
    }
    
    public func accept<Visitor>(visitor: Visitor) throws -> Visitor.Output where Visitor : EventVisitor {
        try visitor.visitDurationEvent(self)
    }
}
