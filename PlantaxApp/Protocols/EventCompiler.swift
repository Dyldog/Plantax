//
//  EventCompiler.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

protocol EventCompiler {
    
}

extension EventCompiler {
    func compileEvents(_ input: String) throws -> [FixedEvent] {
        let scanner = Scanner(source: input)
        let tokens = try scanner.scanTokens()

        let parser = Parser(tokens: tokens)
        let events = try parser.parseEvents()

        let compiler = Compiler(rawEvents: events)
        let flattenedEvents = try compiler.fixEvents()
        
        return flattenedEvents
    }
}
