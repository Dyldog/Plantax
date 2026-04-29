//
//  SeparatedVStack.swift
//  Plannana
//
//  Created by Dylan Elliott on 3/12/2025.
//

import SwiftUI

struct SeparatedVStack<Data, Content: View, Separator: View>: View {
    let data: [Data]
    let content: (Data) -> Content
    let separator: () -> Separator

    private var lastIndex: Int { data.count - 1 }

    init(_ data: [Data], content: @escaping (Data) -> Content, separator: @escaping () -> Separator)
    {
        self.data = data
        self.content = content
        self.separator = separator
    }

    init(
        _ range: Range<Int>, content: @escaping (Data) -> Content,
        separator: @escaping () -> Separator
    ) where Data == Int {
        self.data = Array(range)
        self.content = content
        self.separator = separator
    }

    var body: some View {
        VStack(spacing: .zero) {
            ForEach(0..<data.count, id: \.self) { index in
                content(data[index])

                if index != lastIndex {
                    separator()
                }
            }
        }
    }
}
