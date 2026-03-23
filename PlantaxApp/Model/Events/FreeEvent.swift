//
//  FreeEvent.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

public struct FreeEvent: Event {
    public let title: String
    public let line: Int
    public var boundaries: (start: TimeInterval?, end: TimeInterval?) = (nil, nil)
    public var startTime: EventTime? { nil }
    
    public func accept<Visitor>(visitor: Visitor) throws -> Visitor.Output where Visitor : EventVisitor {
        try visitor.visitFreeEvent(self)
    }
}
