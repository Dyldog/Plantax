//
//  LineError.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation

/// An error associated with a specific source line,
/// suitable for Xcode-style inline annotation.
struct LineError: Identifiable, Equatable {
    let id = UUID()
    let line: Int
    let message: String

    /// Attempts to extract the line number from a compiler pipeline error.
    static func from(_ error: Error) -> LineError {
        switch error {
        case let e as ScannerError:
            return LineError(line: e.line, message: e.message)
        case let e as ParseError:
            return LineError(line: e.token.line, message: e.message)
        default:
            return LineError(line: 0, message: error.localizedDescription)
        }
    }
}
