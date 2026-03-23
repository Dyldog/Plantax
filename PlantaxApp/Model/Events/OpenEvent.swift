//
//  OpenEvent.swift
//  
//
//  Created by Dylan Elliott on 10/1/2026.
//

import Foundation

public struct OpenEvent: Event {
    public let title: String
    public let line: Int
    public let time: EventTime
    public let type: TimeType
    public let children: [EventChild]
    
    public var boundaries: (start: TimeInterval?, end: TimeInterval?) {
        switch type {
        case .start: (time.offset, nil)
        case .end: (nil, time.offset)
        }
    }
    
    public var startTime: EventTime? {
        switch type {
        case .start: time
        case .end: nil
        }
    }
    
    public init(title: String, line: Int, time: EventTime, type: TimeType, children: [EventChild] = []) {
        self.title = title
        self.line = line
        self.time = time
        self.type = type
        self.children = children
    }
    
    public enum TimeType {
        case start
        case end
    }
    
    public func accept<Visitor>(visitor: Visitor) throws -> Visitor.Output where Visitor : EventVisitor {
        try visitor.visitOpenEvent(self)
    }
}
