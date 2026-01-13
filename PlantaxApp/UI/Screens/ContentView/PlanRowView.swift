//
//  PlanRowView.swift
//  Plannana
//
//  Created by Dylan Elliott on 3/12/2025.
//

import SwiftUI

struct PlanRowView<Content: View>: View {
    let model: PlanRowModel
    let content: (PlanRowModel) -> Content
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24).foregroundStyle(model.color)
            content(model)
        }
    }
}
