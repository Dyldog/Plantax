//
//  SyntaxManualView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 11/5/2026.
//

import SwiftUI

struct SyntaxManualView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    overview
                    timesSection
                    datesSection
                    durationsSection
                    eventTypesSection
                    sequencingSection
                    travelSection
                    childEventsSection
                    commentsSection
                    fullExampleSection
                }
                .padding()
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Syntax Manual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Overview

    private var overview: some View {
        section("Overview") {
            Text("Each line in a plan describes a single event. An event line has up to three optional prefixes — a start time, an end time, and a duration — followed by a title.")
            codeBlock("[@[date] time] [-> [date] time] [#duration] Title")
        }
    }

    // MARK: - Times

    private var timesSection: some View {
        section("Times") {
            Text("Times use 12-hour format with a required am/pm suffix. Minutes are optional.")
            codeBlock("""
            @9am Breakfast
            @10:30am Meeting
            ->5pm End of work
            """)
        }
    }

    // MARK: - Dates

    private var datesSection: some View {
        section("Dates") {
            Text("A date can be placed before the time in day/month or day/month/year format. When the year is omitted, the current year is assumed.")
            codeBlock("""
            @23/3 9am Breakfast
            @23/3/2026 10:30am Meeting
            ->24/3 5pm End of trip
            """)
        }
    }

    // MARK: - Durations

    private var durationsSection: some View {
        section("Durations") {
            Text("A duration is written as # followed by a number and a unit — m for minutes, h for hours.")
            codeBlock("""
            #30m Lunch
            #2h Workshop
            #1h30m Long session
            """)
        }
    }

    // MARK: - Event Types

    private var eventTypesSection: some View {
        section("Event Types") {
            Text("How the prefixes combine determines the type of event.")

            eventType(
                "Fixed (start and end)",
                description: "Both start and end are known. The event occupies an exact window.",
                example: "@9am ->10am Standup"
            )

            eventType(
                "Fixed (start/end + duration)",
                description: "A start or end paired with a duration. The missing boundary is calculated.",
                example: """
                @9am #1h Standup
                ->5pm #30m Wrap up
                """
            )

            eventType(
                "Open-start (end only)",
                description: "Only an end time. The event starts at the end of the previous event.",
                example: "->9am Commute"
            )

            eventType(
                "Open-end (start only)",
                description: "Only a start time. The event ends at the start of the next event, so the next event must have a start time.",
                example: """
                @9am Work
                @5pm Finish
                """
            )

            eventType(
                "Duration only",
                description: "No absolute time — just a length. Starts at the end of the previous event.",
                example: "#45m Exercise"
            )

            eventType(
                "Free (title only)",
                description: "No time information at all. Fills the gap between the previous and next events.",
                example: "Free time"
            )
        }
    }

    // MARK: - Sequencing

    private var sequencingSection: some View {
        section("Sequencing Rules") {
            Text("Events are compiled in order. Several types rely on their neighbours.")

            VStack(alignment: .leading, spacing: 8) {
                sequencingRule("Duration-only", requirement: "Must follow an event with an end time")
                sequencingRule("Free", requirement: "Must follow an event with an end time")
                sequencingRule("Open-end", requirement: "Must be followed by an event with a start time")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
        }
    }

    // MARK: - Travel

    private var travelSection: some View {
        section("Travel Events") {
            Text("A travel event calculates the real driving, riding, or walking duration between two locations. Use the keyword followed by origin -> destination.")
            codeBlock("""
            DRIVE Sydney -> Melbourne
            @9am WALK Hotel -> Conference Centre
            RIDE Home -> Airport
            """)
        }
    }

    // MARK: - Child Events

    private var childEventsSection: some View {
        section("Child Events") {
            Text("Any event can have indented child events beneath it. Children describe activities that occur within the parent event.")

            eventType(
                "Schedule windows",
                description: "A clock-time window that activates whenever the wall-clock falls within its range. Indented under the parent.",
                example: """
                @9am ->5pm Work
                    @12pm ->1pm Lunch
                    @3pm ->3:15pm Coffee break
                """
            )

            eventType(
                "Recurring breaks",
                description: "A break that triggers after every interval of accumulated parent-activity time, lasting for a given duration. Written as %interval/duration.",
                example: """
                DRIVE Sydney -> Melbourne
                    %1h/10m Rest stop
                    %2h/15m Stretch break
                """
            )

            Text("Children listed higher take priority when overlapping. For travel events, children extend the journey. For other events, children subdivide the parent's time window.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Comments

    private var commentsSection: some View {
        section("Comments") {
            Text("Lines starting with // are comments and are ignored. Empty lines are also allowed.")
            codeBlock("""
            // Morning routine
            @7am ->8am Breakfast

            // Work block
            @9am ->5pm Work
            """)
        }
    }

    // MARK: - Full Example

    private var fullExampleSection: some View {
        section("Full Example") {
            codeBlock("""
            ->9am Commute
            @9am ->9:15am Standup
            #45m Deep work
            @10am ->12pm Meetings
            Free time
            @12:30pm #1h Lunch
            @1:30pm Work
            @5pm ->5:30pm Wrap up
            """)
        }
    }

    // MARK: - Reusable Components

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.weight(.bold))

            content()
        }
    }

    private func eventType(_ title: String, description: String, example: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(description)
                .font(.subheadline)

            codeBlock(example)
        }
        .padding(.top, 4)
    }

    private func codeBlock(_ code: String) -> some View {
        Text(code)
            .font(.system(.callout, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
    }

    private func sequencingRule(_ type: String, requirement: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(type)
                .font(.subheadline.weight(.semibold))
                .frame(width: 100, alignment: .leading)

            Text(requirement)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
