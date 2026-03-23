//
//  ContentViewModel.swift
//  Plannana
//
//  Created by Dylan Elliott on 3/12/2025.
//

import Combine
import SwiftUI

class ContentViewModel: ObservableObject, EventCompiler {
    @Published var rows: [PlanRowModel]
    
    init() {
        self.rows = []
        Task {
            let rows = await makeRows(from: """
                @12pm->1pm Lunch 
                #30m Exercise
                ->5pm Working from office
                @5pm->8pm Thing
                ->12am Other Thing
                """)
            await MainActor.run {
                self.rows = rows
            }
        }
    }
    
    var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    
    private func makeRows(from input: String) async -> [PlanRowModel] {
        do {
            return try await compileEvents(input).map { event in
                let model = PlanRowModel(
                    title: event.title,
                    timeDescription: event.timeDescription,
                    color: colors.randomElement()!,
                    start: event.start.offset,
                    duration: event.end.offset - event.start.offset
                )
                print(event)
                print(model)
                return model
            }
        } catch {
            print("Error compiling events: \(error.localizedDescription)")
            return []
        }
    }
}

private extension Date {
    var offset: CGFloat {
        let secondsInADay = 60 * 60 * 24
        let offsetInterval = timeIntervalSinceReferenceDate - startOfDay.timeIntervalSinceReferenceDate
        return offsetInterval / Double(secondsInADay) * Double(24)
    }
}
