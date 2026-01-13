//
//  NewContentRowModel.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

struct NewContentRowModel: Hashable, Equatable {
    let title: String
    let time: String
    let timeDescription: String
    let occurrence: Occurrence
    
    enum Occurrence {
        case past
        case present
        case future
        
        var isPassed: Bool { self == .past }
    }
}
