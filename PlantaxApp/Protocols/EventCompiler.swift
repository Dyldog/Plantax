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
    func compileEvents(_ input: String) async throws -> [FixedEvent] {
        let scanner = Scanner(source: input)
        let tokens = try scanner.scanTokens()

        let parser = Parser(tokens: tokens)
        let events = try parser.parseEvents()

        // Resolve travel events to concrete durations before compiling.
        let resolvedEvents = try await TravelDurationResolver.resolveAll(events)

        let compiler = Compiler(rawEvents: resolvedEvents)
        let flattenedEvents = try compiler.fixEvents()
        
        return flattenedEvents
    }
}
