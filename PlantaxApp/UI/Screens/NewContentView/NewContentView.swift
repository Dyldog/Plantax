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
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.rows) { model in
                        row(with: model)
                            .id(model.id)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .onAppear {
                if let activeId = viewModel.currentEventId {
                    proxy.scrollTo(activeId, anchor: .top)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Plan")
    }

    // MARK: - Row Dispatch

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
                eventCard(with: event)
            }
        case let .freeTime(event):
            freeTimeRow(with: event)
        }
    }

    // MARK: - Date Header

    private func dateHeader(_ label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(label)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Parent Row (collapsible)

    private func parentRow(with model: NewContentRowModel) -> some View {
        let isCollapsed = !viewModel.expandedParents.contains(model.id)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.toggleCollapse(for: model.id)
            }
        } label: {
            eventCardContent(
                title: model.title,
                timeDescription: model.timeDescription,
                time: model.time,
                occurrence: model.occurrence,
                isContinuation: model.isContinuation,
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                }
            )
            .cardStyle(occurrence: model.occurrence)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Child Row

    private func childRow(with model: NewContentRowModel) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(accentColor(for: model.occurrence).opacity(0.5))
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(model.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(model.occurrence == .past ? .secondary : .primary)

                HStack(spacing: 4) {
                    Text(model.time)
                        .font(.caption2)

                    if !model.timeDescription.isEmpty {
                        Text("·")
                        Text(model.timeDescription)
                            .font(.caption2)
                    }
                }
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
        .padding(.leading, 20)
        .padding(.top, 3)
        .withOccurrence(model.occurrence)
    }

    // MARK: - Event Card

    private func eventCard(with model: NewContentRowModel) -> some View {
        eventCardContent(
            title: model.title,
            timeDescription: model.timeDescription,
            time: model.time,
            occurrence: model.occurrence,
            isContinuation: model.isContinuation
        )
        .cardStyle(occurrence: model.occurrence)
    }

    // MARK: - Free Time Row

    private func freeTimeRow(with model: FreeTimeRowModel) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text(model.title)
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            dashedLine

            Text(model.time)
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .withOccurrence(model.occurrence)
    }

    private var dashedLine: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: .init(x: 0, y: geo.size.height / 2))
                path.addLine(to: .init(x: geo.size.width, y: geo.size.height / 2))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(.quaternary)
        }
        .frame(height: 1)
    }

    // MARK: - Card Content

    @ViewBuilder
    private func eventCardContent<Trailing: View>(
        title: String,
        timeDescription: String,
        time: String,
        occurrence: NewContentRowModel.Occurrence,
        isContinuation: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if isContinuation {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(occurrence == .past ? .secondary : .primary)
                    .lineLimit(2)
                    .layoutPriority(1)

                Spacer(minLength: 4)

                if !timeDescription.isEmpty {
                    Text(timeDescription)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(durationColor(for: occurrence))
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(durationColor(for: occurrence).opacity(0.12))
                        )
                }

                trailing()
            }

            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.caption2)
                Text(time)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .withOccurrence(occurrence)
    }

    // MARK: - Helpers

    private func accentColor(for occurrence: NewContentRowModel.Occurrence) -> Color {
        switch occurrence {
        case .past: .secondary
        case .present: .green
        case .future: .accentColor
        }
    }

    private func durationColor(for occurrence: NewContentRowModel.Occurrence) -> Color {
        switch occurrence {
        case .past: .secondary
        case .present: .green
        case .future: .accentColor
        }
    }
}

// MARK: - View Modifiers

private extension View {
    func cardStyle(occurrence: NewContentRowModel.Occurrence) -> some View {
        self
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
            )
            .overlay(alignment: .leading) {
                UnevenRoundedRectangle(
                    topLeadingRadius: 14,
                    bottomLeadingRadius: 14,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
                .fill(occurrence == .present ? Color.green : .clear)
                .frame(width: 4)
            }
            .padding(.top, 6)
    }

    @ViewBuilder
    func withOccurrence(_ occurrence: NewContentRowModel.Occurrence) -> some View {
        if occurrence == .past {
            self.opacity(0.6)
        } else {
            self
        }
    }
}
