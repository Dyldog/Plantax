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
        List {
            ForEach(viewModel.rows) { model in
                row(with: model)
            }
            .listRowInsets(.init())
        }
        .listStyle(.plain)
        .navigationTitle("Plan")
    }
    
    @ViewBuilder
    private func row(with model: NewPlanRowModel) -> some View {
        switch model {
        case let .dateHeader(label):
            dateHeader(label)
        case let .event(event):
            if event.isChild {
                childRow(with: event)
            } else if event.hasChildren {
                parentRow(with: event)
            } else {
                eventRow(
                    with: event.title,
                    timeDescription: event.timeDescription,
                    time: event.time,
                    occurrence: event.occurrence
                )
            }
        case let .freeTime(event):
            eventRow(
                with: event.title,
                timeDescription: event.timeDescription,
                time: event.time,
                occurrence: event.occurrence
            )
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
    
    // MARK: - Parent Row (collapsible)
    
    private func parentRow(with model: NewContentRowModel) -> some View {
        let isCollapsed = viewModel.collapsedParents.contains(model.id)
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleCollapse(for: model.id)
            }
        } label: {
            HStack(spacing: 0) {
                eventRow(
                    with: model.title,
                    timeDescription: model.timeDescription,
                    time: model.time,
                    occurrence: model.occurrence
                )
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                    .padding(.trailing)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Child Row (indented with vertical bar)
    
    private func childRow(with model: NewContentRowModel) -> some View {
        HStack(spacing: 0) {
            // Vertical bar
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color.accentColor.opacity(0.5))
                .frame(width: 3)
                .padding(.leading, 20)
            
            eventRow(
                with: model.title,
                timeDescription: model.timeDescription,
                time: model.time,
                occurrence: model.occurrence
            )
            .padding(.leading, 4)
        }
    }
    
    // MARK: - Base Event Row
    
    @ViewBuilder
    private func eventRow(with title: String, timeDescription: String, time: String, occurrence: NewContentRowModel.Occurrence) -> some View {
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
