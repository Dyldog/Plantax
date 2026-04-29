//
//  ContentView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Combine
import SwiftUI

struct ContentView: View {
    private let pixelsPerHour: CGFloat = 40

    @StateObject var viewModel: ContentViewModel = .init()

    var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                timeline
                events
            }
        }
    }

    private var timeline: some View {
        SeparatedVStack(0..<24) { hour in
            Text("\(hour % 12):00\(hour <= 12 ? "am" : "pm")")
                .frame(width: 100, height: pixelsPerHour - 1)
        } separator: {
            Rectangle()
                .foregroundStyle(.black)
                .frame(height: 1)
        }
        .fixedSize()
    }

    private var events: some View {
        ZStack(alignment: .top) {
            ForEach(viewModel.rows) { row in
                PlanRow(model: row)
                    .offset(y: row.start * pixelsPerHour)
                    .frame(maxWidth: .infinity)
                    .frame(height: row.duration * pixelsPerHour)
            }
        }
    }
}

#Preview {
    ContentView()
}
