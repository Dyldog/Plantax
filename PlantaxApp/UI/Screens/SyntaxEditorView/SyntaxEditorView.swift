//
//  SyntaxEditorView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import SwiftUI

/// A code editor with live syntax highlighting and Xcode-style
/// inline error annotations. Validates on every keystroke.
struct SyntaxEditorView: View {
    @Binding var text: String

    let onShowTapped: (String) -> Void

    @State private var errors: [LineError] = []

    var body: some View {
        HighlightedTextEditor(text: $text, errors: errors)
            .onChange(of: text) { _, newValue in
                validate(newValue)
            }
            .onAppear {
                validate(text)
            }
            .toolbar {
                Button("Show", systemImage: "eye.fill") {
                    onShowTapped(text)
                }
            }
    }

    // MARK: - Validation

    private func validate(_ source: String) {
        guard !source.isEmpty else {
            errors = []
            return
        }

        do {
            let scanner = Scanner(source: source)
            let tokens = try scanner.scanTokens()
            let parser = Parser(tokens: tokens)
            _ = try parser.parseEvents()
            errors = []
        } catch {
            errors = [LineError.from(error)]
        }
    }
}
