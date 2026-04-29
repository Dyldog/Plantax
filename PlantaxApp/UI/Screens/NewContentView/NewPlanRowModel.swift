//
//  PlannedEvent.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

enum NewPlanRowModel: Hashable, Equatable, Identifiable {
    case dateHeader(String)
    case event(NewContentRowModel)
    case freeTime(FreeTimeRowModel)

    var id: Int {
        switch self {
        case .dateHeader(let label): label.hashValue
        case .event(let model): model.id
        case .freeTime(let model): model.id
        }
    }
}
