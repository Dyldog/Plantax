//
//  OpenEvent.swift
//  
//
//  Created by Dylan Elliott on 10/1/2026.
//

import Foundation

public struct OpenEvent: Event {
    public let title: String
    public let time: TimeInterval
    public let type: TimeType
    
    public var boundaries: (start: TimeInterval?, end: TimeInterval?) {
        switch type {
        case .start: (time, nil)
        case .end: (nil, time)
        }
    }
    public init(title: String, time: TimeInterval, type: TimeType) {
        self.title = title
        self.time = time
        self.type = type
    }
    
    public enum TimeType {
        case start
        case end
    }
    
    public func accept<Visitor>(visitor: Visitor) throws -> Visitor.Output where Visitor : EventVisitor {
        try visitor.visitOpenEvent(self)
    }
}
