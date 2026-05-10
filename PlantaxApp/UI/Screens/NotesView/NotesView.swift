//
//  NotesView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 11/5/2026.
//

import SwiftUI

struct NotesView: View {
    @Binding var notes: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TextEditor(text: $notes)
                .navigationTitle("Notes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}
