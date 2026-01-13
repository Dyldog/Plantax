//
//  PlanRowModel.swift
//  Plannana
//
//  Created by Dylan Elliott on 3/12/2025.
//

import SwiftUI

struct PlanRowModel: Identifiable {
    let id: UUID = .init()
    let title: String
    let timeDescription: String
    let color: Color
    let start: CGFloat // Hours from midnight
    let duration: CGFloat // Hours
}
