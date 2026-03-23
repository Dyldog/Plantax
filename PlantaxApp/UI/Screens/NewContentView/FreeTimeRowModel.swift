//
//  FreeTimeRowModel.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

struct FreeTimeRowModel: Hashable, Equatable, Identifiable {
    let id: Int
    let title: String
    let timeDescription: String
    let time: String
    let occurrence: NewContentRowModel.Occurrence
}
