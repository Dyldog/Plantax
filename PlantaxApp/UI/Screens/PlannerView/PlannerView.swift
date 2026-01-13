//
//  PlannerView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import SwiftUI
import Combine

class PlannerViewModel: ObservableObject, EventCompiler {
    @Published var errorMessage: String?
    @Published var events: [FixedEvent]?
    
    func didTapShow(with input: String) {
        do {
            events = try compileEvents(input)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


struct PlannerView: View {
    @StateObject var viewModel: PlannerViewModel = .init()
    
    var body: some View {
        NavigationStack {
            EditorView { input in
                viewModel.didTapShow(with: input)
            }
            .navigationTitle("Planana")
            .alert(item: $viewModel.errorMessage) { message in
                Alert(title: Text("Error"), message: Text(message))
            }
            .navigationDestination(item: $viewModel.events) { events in
                NewContentView(events: events)
            }
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
