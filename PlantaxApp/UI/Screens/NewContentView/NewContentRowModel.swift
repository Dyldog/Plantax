//
//  NewContentRowModel.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

struct NewContentRowModel: Hashable, Equatable, Identifiable {
    let id: Int
    let title: String
    let time: String
    let timeDescription: String
    let occurrence: Occurrence
    let isChild: Bool
    let hasChildren: Bool
    /// `true` when this row represents a continuation of a multi-day event on a subsequent day.
    let isContinuation: Bool
    /// Non-nil when this row represents a travel event.
    let travelInfo: TravelInfo?
    
    init(
        id: Int,
        title: String,
        time: String,
        timeDescription: String,
        occurrence: Occurrence,
        isChild: Bool,
        hasChildren: Bool,
        isContinuation: Bool = false,
        travelInfo: TravelInfo? = nil
    ) {
        self.id = id
        self.title = title
        self.time = time
        self.timeDescription = timeDescription
        self.occurrence = occurrence
        self.isChild = isChild
        self.hasChildren = hasChildren
        self.isContinuation = isContinuation
        self.travelInfo = travelInfo
    }
    
    enum Occurrence {
        case past
        case present
        case future
        
        var isPassed: Bool { self == .past }
    }
}
