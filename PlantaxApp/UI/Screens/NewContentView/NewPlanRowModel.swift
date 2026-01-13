//
//  PlannedEvent.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

enum NewPlanRowModel: Hashable, Equatable {
    case event(NewContentRowModel)
    case freeTime(FreeTimeRowModel)
}
