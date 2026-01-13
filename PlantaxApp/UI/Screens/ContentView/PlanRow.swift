//
//  PlanRow.swift
//  Plannana
//
//  Created by Dylan Elliott on 3/12/2025.
//

import SwiftUI

struct PlanRow: View {
    let model: PlanRowModel
    
    var body: some View {
        PlanRowView(model: model) { model in
            HStack(alignment: .top) {
                Text(model.title)
                    .padding()
                    .foregroundStyle(.white)
                    .bold()
                
                Spacer()
                
                Text(model.timeDescription)
                    .padding()
                    .foregroundStyle(.white)
                    .bold()
            }
        }
    }
}
