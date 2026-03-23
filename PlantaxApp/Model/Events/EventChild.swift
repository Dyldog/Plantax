//
//  EventChild.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import Foundation

/// A child activity that occurs within a parent event.
public protocol EventChild {
    var title: String { get }
}
