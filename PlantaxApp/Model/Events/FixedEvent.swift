//
//  FixedEvent.swift
//  
//
//  Created by Dylan Elliott on 13/1/2026.
//

import Foundation

/// Travel metadata attached to a `FixedEvent` when it originates from a travel event.
public struct TravelInfo: Hashable {
    public let mode: TravelMode
    public let origin: String
    public let destination: String
    
    /// A Google Maps directions URL for this trip.
    public var googleMapsURL: URL? {
        let travelMode: String = switch mode {
        case .drive: "driving"
        case .ride: "bicycling"
        case .walk: "walking"
        }
        
        var components = URLComponents(string: "https://www.google.com/maps/dir/")!
        components.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination),
            URLQueryItem(name: "travelmode", value: travelMode),
        ]
        return components.url
    }
}

public struct FixedEvent: Hashable {
    public let title: String
    public let timeDescription: String
    public let start: Date
    public let end: Date
    /// Sub-events that occur within this event (e.g. drive segments, breaks, sleep during travel).
    public let children: [FixedEvent]
    /// Non-nil when this event represents a travel leg (drive, ride, walk).
    public let travelInfo: TravelInfo?
    
    public init(
        title: String,
        timeDescription: String,
        start: Date,
        end: Date,
        children: [FixedEvent] = [],
        travelInfo: TravelInfo? = nil
    ) {
        self.title = title
        self.timeDescription = timeDescription
        self.start = start
        self.end = end
        self.children = children
        self.travelInfo = travelInfo
    }
}
