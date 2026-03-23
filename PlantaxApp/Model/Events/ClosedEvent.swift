//
//  ClosedEvent.swift
//  
//
//  Created by Dylan Elliott on 10/1/2026.
//

import Foundation

public struct ClosedEvent: Event {
    public let start: EventTime
    public let end: EventTime
    public let title: String
    
    public var boundaries: (start: TimeInterval?, end: TimeInterval?) { (start.offset, end.offset) }
    
    public init(start: EventTime, end: EventTime, title: String) {
        self.start = start
        self.end = end
        self.title = title
    }
    
    public func accept<Visitor>(visitor: Visitor) throws -> Visitor.Output where Visitor : EventVisitor {
        try visitor.visitClosedEvent(self)
    }
}
