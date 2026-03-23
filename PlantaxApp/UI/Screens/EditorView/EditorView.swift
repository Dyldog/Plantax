//
//  EditorView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import SwiftUI

struct EditorView: View {
    @Binding var text: String

    let onShowTapped: (String) -> Void
    
    var body: some View {
        TextEditor(text: $text)
            .toolbar {
                Button("Show", systemImage: "eye.fill") {
                    onShowTapped(text)
                }
            }
    }
}
