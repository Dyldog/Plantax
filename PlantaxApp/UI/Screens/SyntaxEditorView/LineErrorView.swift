//
//  LineErrorView.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import SwiftUI

/// An Xcode-style inline error annotation shown beneath a source line.
struct LineErrorView: View {
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.white)
                .font(.caption)

            Text(message)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(3)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.red.opacity(0.85))
        )
    }
}
