//
//  TravelDurationResolver.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation
import MapKit

struct ResolvedTravel {
    let duration: TimeInterval
    let mode: TravelMode
    let origin: String
    let destination: String
}

enum TravelDurationResolver {
    /// Resolves the travel duration for a given mode and locations
    /// using MapKit directions.
    static func resolve(
        mode: TravelMode,
        origin: String,
        destination: String
    ) async throws -> TimeInterval {
        let originItem = try await geocode(origin)
        let destinationItem = try await geocode(destination)

        let request = MKDirections.Request()
        request.source = originItem
        request.destination = destinationItem
        request.transportType = mode.transportType

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        guard let route = response.routes.first else {
            throw TravelResolverError.noRouteFound(from: origin, to: destination)
        }

        return route.expectedTravelTime * mode.durationMultiplier
    }

    /// Resolves all `TravelEvent`s in the list, replacing them with
    /// `DurationEvent`s or `ClosedEvent`s (when a start time is present).
    static func resolveAll(_ events: [Event]) async throws -> [Event] {
        var resolved: [Event] = []

        for event in events {
            guard let travel = event as? TravelEvent else {
                resolved.append(event)
                continue
            }

            let duration = try await resolve(
                mode: travel.mode,
                origin: travel.origin,
                destination: travel.destination
            )

            if travel.children.isEmpty {
                // No children — collapse into a simple event.
                if let start = travel.start {
                    let endTime = EventTime(
                        offset: start.offset + duration,
                        date: start.date
                    )
                    resolved.append(ClosedEvent(
                        start: start,
                        end: endTime,
                        title: travel.title,
                        line: travel.line
                    ))
                } else {
                    resolved.append(DurationEvent(
                        title: travel.title,
                        line: travel.line,
                        duration: duration
                    ))
                }
            } else {
                // Keep as TravelEvent with the resolved duration so
                // the Compiler can expand the schedule with children.
                resolved.append(TravelEvent(
                    title: travel.title,
                    line: travel.line,
                    mode: travel.mode,
                    origin: travel.origin,
                    destination: travel.destination,
                    start: travel.start,
                    children: travel.children,
                    resolvedDuration: duration
                ))
            }
        }

        return resolved
    }

    // MARK: - Geocoding

    private static func geocode(_ address: String) async throws -> MKMapItem {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        guard let item = response.mapItems.first else {
            throw TravelResolverError.locationNotFound(address)
        }

        return item
    }
}

enum TravelResolverError: LocalizedError {
    case locationNotFound(String)
    case noRouteFound(from: String, to: String)

    var errorDescription: String? {
        switch self {
        case let .locationNotFound(location):
            "Could not find location: \(location)"
        case let .noRouteFound(from, to):
            "No route found from \(from) to \(to)"
        }
    }
}
