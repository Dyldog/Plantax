//
//  EditorView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import SwiftUI
import Combine

class EditorViewModel: ObservableObject {
    @Published(key: "inputText") var text: String = """
    @12pm->1pm Lunch 
    #30m Exercise
    ->5pm Working from office
    @5pm->8pm Thing
    ->12am Other Thing
    """
}

struct EditorView: View {
    @StateObject var viewModel: EditorViewModel = .init()
    
    let onShowTapped: (String) -> Void
    
    var body: some View {
        TextEditor(text: $viewModel.text)
            .toolbar {
                Button("Show", systemImage: "eye.fill") {
                    onShowTapped(viewModel.text)
                }
            }
    }
}
