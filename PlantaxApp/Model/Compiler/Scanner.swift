//
//  Scanner.swift
//  
//
//  Created by Dylan Elliott on 5/1/2026.
//

import Foundation

struct ScannerError: LocalizedError {
    let message: String
    let line: Int
    
    var errorDescription: String? {
        message
    }
}

public class Scanner {
    var line = 1
    var start = 0
    var current = 0
    var atLineStart = true
    
    let source: String
    
    private var tokens: [Token] = []
    
    let keywords: [String: TokenType] = [
        "am": .am,
        "pm": .pm,
        "m": .minutes,
        "h": .hours,
        "drive": .drive,
        "ride": .ride,
        "walk": .walk,
    ]
    
    public init(source: String) {
        self.source = source
    }
    
    public func scanTokens() throws -> [Token] {
        while !isAtEnd {
            start = current
            try scanToken()
        }
        
        tokens.append(Token(type: .endOfFile, lexeme: "", literal: nil, line: line))
        
        return tokens
    }
    
    private func scanToken() throws {
        let char = advance()
        
        switch char {
        case " ":
            if atLineStart {
                while peek() == " " { _ = advance() }
                addToken(type: .indent, literal: current - start)
                atLineStart = false
            }
            return
        case "\n":
            addToken(type: .newline)
            line += 1
            atLineStart = true
            return
        default:
            break
        }
        
        atLineStart = false
        
        switch char {
        case "@": addToken(type: .at)
        case "%": addToken(type: .percent)
        case "#": addToken(type: .hash)
        case ":": addToken(type: .colon)
        case "/": addToken(type: .slash)
        case "-": try arrow()
        default:
            if char.isNumber {
                number()
            } else if char.isAlphanumeric {
                identifier()
            } else {
                try error("Unexpected character '\(char)'")
            }
        }
    }
    
    private func advance() -> Character {
        let char = source[current]
        current += 1
        return char
    }
    
    private func peek() -> Character {
        guard !isAtEnd else { return "\0" }
        return source[current]
    }
    
    private func addToken(type: TokenType) {
        addToken(type: type, literal: nil);
    }
    
    private func addToken(type: TokenType, literal: Any?) {
        let text = source.substring(with: (start..<current))
        tokens.append(Token(type: type, lexeme: text, literal: literal, line: line))
    }
    
    private var currentLexeme: String {
        source.substring(with: (start..<current))
    }
    
    private var isAtEnd: Bool {
        current >= source.count
    }
    
    // MARK: - Lexeme Types
    
    private func number() {
        while peek().isNumber { _ = advance() }
        addToken(type: .number, literal: Int(currentLexeme))
    }
    
    private func identifier() {
        while peek().isLetter { _ = advance() }
        
        let type = keywords[currentLexeme.lowercased()] ?? .word
        
        addToken(type: type, literal: currentLexeme)
    }
    
    private func arrow() throws {
        guard peek() == ">" else { try error("Expected '>' to complete '-'"); return }
        
        _ = advance() // Consume '>'
        
        addToken(type: .arrow)
    }
    
    // Error Handling
    
    private func error(_ message: String) throws {
        throw ScannerError(message: message, line: line)
    }
}
