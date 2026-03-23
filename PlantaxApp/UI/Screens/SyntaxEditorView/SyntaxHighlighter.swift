//
//  SyntaxHighlighter.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import SwiftUI

/// A token with its character range in the source string.
struct PositionedToken {
    let type: TokenType
    let range: NSRange
}

/// Maps token types to syntax highlighting colours and
/// provides positioned token scanning for range-based colouring.
enum SyntaxHighlighter {
    /// Returns the display colour for a given token type.
    static func color(for type: TokenType) -> Color {
        switch type {
        case .at, .arrow, .hash:
            return .purple
        case .number:
            return .blue
        case .colon, .slash:
            return .secondary
        case .am, .pm, .minutes, .hours:
            return .teal
        case .word:
            return .primary
        case .newline, .endOfFile:
            return .clear
        }
    }

    /// Scans the source and returns tokens with their character
    /// ranges so highlighting can be applied to the original text
    /// without losing whitespace.
    static func positionedTokens(from source: String) -> [PositionedToken] {
        let scanner = Scanner(source: source)
        guard let tokens = try? scanner.scanTokens() else { return [] }

        var result: [PositionedToken] = []
        var searchStart = source.startIndex

        for token in tokens {
            guard token.type != .endOfFile else { continue }

            let lexeme = token.type == .newline ? "\n" : token.lexeme

            guard let range = source.range(of: lexeme, range: searchStart..<source.endIndex) else {
                continue
            }

            let nsRange = NSRange(range, in: source)
            result.append(PositionedToken(type: token.type, range: nsRange))
            searchStart = range.upperBound
        }

        return result
    }
}
