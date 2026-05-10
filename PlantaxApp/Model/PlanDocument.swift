//
//  PlanDocument.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let plantaxPlan = UTType(exportedAs: "com.dylan.plantax.plan")
}

struct PlanDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plantaxPlan] }

    var text: String
    var notes: String

    init(text: String = "", notes: String = "") {
        self.text = text
        self.notes = notes
    }

    // MARK: - Persistence

    private struct Storage: Codable {
        var text: String
        var notes: String
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        // Try JSON first, fall back to legacy plain-text
        if let storage = try? JSONDecoder().decode(Storage.self, from: data) {
            text = storage.text
            notes = storage.notes
        } else {
            text = string
            notes = ""
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let storage = Storage(text: text, notes: notes)
        let data = try JSONEncoder().encode(storage)
        return FileWrapper(regularFileWithContents: data)
    }
}
