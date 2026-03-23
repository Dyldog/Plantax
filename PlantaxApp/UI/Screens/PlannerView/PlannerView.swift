//
//  PlannerView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import SwiftUI
import Combine

struct CompiledPlan: Identifiable, Hashable {
    let id = UUID()
    let events: [FixedEvent]
}

class PlannerViewModel: ObservableObject, EventCompiler {
    @Published var errorMessage: String?
    @Published var compiledPlan: CompiledPlan?
    
    func didTapShow(with input: String) {
        do {
            compiledPlan = CompiledPlan(events: try compileEvents(input))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct PlannerView: View {
    @Binding var document: PlanDocument
    @StateObject private var viewModel: PlannerViewModel = .init()
    
    var body: some View {
        NavigationStack {
            EditorView(text: $document.text) { input in
                viewModel.didTapShow(with: input)
            }
            .alert(item: $viewModel.errorMessage) { message in
                Alert(title: Text("Error"), message: Text(message))
            }
            .navigationDestination(item: $viewModel.compiledPlan) { plan in
                NewContentView(events: plan.events)
            }
        }
        .hidingParentNavigationBar()
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
