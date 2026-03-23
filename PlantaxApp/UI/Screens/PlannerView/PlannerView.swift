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

enum EditorType: String, CaseIterable {
    case plain = "Plain"
    case syntax = "Syntax"
}

struct PlannerView: View {
    @Binding var document: PlanDocument
    @StateObject private var viewModel: PlannerViewModel = .init()
    @State private var editorType: EditorType = .syntax
    
    var body: some View {
        NavigationStack {
            editor
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Picker("Editor", selection: $editorType) {
                            ForEach(EditorType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
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

    @ViewBuilder
    private var editor: some View {
        switch editorType {
        case .plain:
            EditorView(text: $document.text) { input in
                viewModel.didTapShow(with: input)
            }
        case .syntax:
            SyntaxEditorView(text: $document.text) { input in
                viewModel.didTapShow(with: input)
            }
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
