//
//  Token.swift
//  
//
//  Created by Dylan Elliott on 5/1/2026.
//

public enum TokenType {
    case at
    case number
    case colon
    case slash
    case am
    case pm
    case minutes
    case hours
    case word
    case arrow
    case hash
    case newline
    case endOfFile
    case drive
    case ride
    case walk
}

public struct Token {
    public let type: TokenType
    public let lexeme: String
    public let literal: Any?
    public let line: Int
    
    public init(type: TokenType, lexeme: String, literal: Any?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
}
