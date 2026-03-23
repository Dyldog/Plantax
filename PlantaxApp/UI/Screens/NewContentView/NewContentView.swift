//
//  NewContentView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import SwiftUI

struct NewContentView: View {
    @StateObject var viewModel: NewContentViewModel
    
    init(events: [FixedEvent]) {
        self._viewModel = .init(wrappedValue: .init(events: events))
    }
    
    var body: some View {
//        TimelineView(.everyMinute) { _ in
            List {
                ForEach(viewModel.rows, id: \.self) { model in
                    row(with: model)
                }
                .listRowInsets(.init())
            }
            .listStyle(.plain)
            .navigationTitle("Plan")
//        }
    }
    
    @ViewBuilder
    private func row(with model: NewPlanRowModel) -> some View {
        switch model {
        case let .dateHeader(label):
            dateHeader(label)
        case let .event(event):
            row(
                with: event.title,
                timeDescription: event.timeDescription,
                time: event.time,
                occurrence: event.occurrence)
        case let .freeTime(event):
            row(
                with: event.title,
                timeDescription: event.timeDescription,
                time: event.time,
                occurrence: event.occurrence)
            .background(.gray.opacity(0.4))
            .foregroundStyle(.white)
        }
    }
    
    private func dateHeader(_ label: String) -> some View {
        Text(label)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGroupedBackground))
    }
    
    @ViewBuilder
    private func row(with title: String, timeDescription: String, time: String, occurrence: NewContentRowModel.Occurrence) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(timeDescription)
            }
            
            Text(time)
        }
        .padding()
        .withOccurrence(occurrence)
    }
}

private extension View {
    @ViewBuilder
    func withOccurrence(_ occurrence: NewContentRowModel.Occurrence) -> some View {
        self
            .strikethrough(occurrence == .past, color: .red)
            .border(occurrence == .present ? .green : .clear, width: 2)
    }
}
