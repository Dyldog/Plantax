//
//  HighlightedTextEditor.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import SwiftUI
import UIKit

/// A `UITextView`-backed editor that applies live syntax highlighting
/// and renders Xcode-style inline error annotations on specific lines.
struct HighlightedTextEditor: UIViewRepresentable {
    @Binding var text: String
    let errors: [LineError]

    private static let monoFont = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = Self.monoFont
        textView.backgroundColor = .systemBackground
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.keyboardType = .asciiCapable
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            let selected = textView.selectedRange
            textView.attributedText = Self.buildAttributedString(from: text)
            textView.selectedRange = selected
        }

        applyErrorAnnotations(to: textView)
    }

    // MARK: - Highlighting

    static func buildAttributedString(from source: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        // Start with the full source in default styling, preserving all whitespace.
        let defaultAttrs: [NSAttributedString.Key: Any] = [
            .font: monoFont,
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle,
        ]
        let result = NSMutableAttributedString(string: source, attributes: defaultAttrs)

        // Overlay syntax colours on each token's exact range.
        for token in SyntaxHighlighter.positionedTokens(from: source) {
            let color = UIColor(SyntaxHighlighter.color(for: token.type))
            result.addAttribute(.foregroundColor, value: color, range: token.range)
        }

        return result
    }

    // MARK: - Error Annotations

    private func applyErrorAnnotations(to textView: UITextView) {
        // Remove previous error subviews
        for subview in textView.subviews where subview.tag == 9999 {
            subview.removeFromSuperview()
        }

        guard !errors.isEmpty else { return }

        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        let fullText = textView.text ?? ""

        guard !fullText.isEmpty else { return }

        let lines = fullText.components(separatedBy: "\n")

        for error in errors {
            let lineIndex = error.line - 1
            guard lineIndex >= 0, lineIndex < lines.count else { continue }

            // Character offset to start of this line
            let charOffset = lines.prefix(lineIndex).reduce(0) { $0 + $1.count + 1 }
            let lineLength = max(lines[lineIndex].count, 1)
            let clampedLocation = min(charOffset, max(fullText.count - 1, 0))
            let clampedLength = min(lineLength, fullText.count - clampedLocation)
            let nsRange = NSRange(location: clampedLocation, length: max(clampedLength, 1))

            // Glyph bounding rect for the line
            let glyphRange = layoutManager.glyphRange(
                forCharacterRange: nsRange, actualCharacterRange: nil)
            let lineRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

            let inset = textView.textContainerInset
            let origin = CGPoint(
                x: inset.left + lineRect.minX,
                y: inset.top + lineRect.maxY + 2
            )

            let hostingController = UIHostingController(
                rootView: LineErrorView(message: error.message))
            hostingController.view.backgroundColor = .clear
            let maxWidth = textView.bounds.width - inset.left - inset.right
            let size = hostingController.view.sizeThatFits(
                CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
            hostingController.view.frame = CGRect(origin: origin, size: size)
            hostingController.view.tag = 9999
            textView.addSubview(hostingController.view)
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightedTextEditor

        init(parent: HighlightedTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // Re-apply highlighting on every edit
            let selected = textView.selectedRange
            parent.text = textView.text

            textView.attributedText = HighlightedTextEditor.buildAttributedString(
                from: textView.text)

            // Restore cursor position
            if selected.location <= (textView.text?.count ?? 0) {
                textView.selectedRange = selected
            }
        }
    }
}
