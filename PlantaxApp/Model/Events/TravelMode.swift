//
//  TravelMode.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation
import MapKit

public enum TravelMode: String {
    case drive
    case ride
    case walk

    var transportType: MKDirectionsTransportType {
        switch self {
        case .drive: .automobile
        case .ride: .automobile // Uses driving route; duration is adjusted later
        case .walk: .walking
        }
    }

    /// Multiplier applied to the raw MapKit ETA to account for
    /// transport differences (e.g. cycling is slower than driving).
    var durationMultiplier: Double {
        switch self {
        case .drive: 1.0
        case .ride: 2.5
        case .walk: 1.0
        }
    }

    var displayName: String {
        switch self {
        case .drive: "Drive"
        case .ride: "Ride"
        case .walk: "Walk"
        }
    }
}
