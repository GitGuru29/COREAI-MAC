import AppKit
import SwiftUI

struct ComposerTextView: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let textView = SubmitTextView()
        textView.delegate = context.coordinator
        textView.drawsBackground = false
        textView.isRichText = false
        textView.importsGraphics = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isAutomaticTextCompletionEnabled = false
        textView.font = .systemFont(ofSize: NSFont.systemFontSize)
        textView.textContainerInset = NSSize(width: 0, height: 10)
        textView.submitHandler = onSubmit
        textView.placeholder = placeholder

        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? SubmitTextView else {
            return
        }

        textView.submitHandler = onSubmit
        textView.placeholder = placeholder

        if textView.string != text {
            textView.string = text
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        let onSubmit: () -> Void

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            self._text = text
            self.onSubmit = onSubmit
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            text = textView.string
        }
    }
}

private final class SubmitTextView: NSTextView {
    var submitHandler: (() -> Void)?
    var placeholder: String = ""

    override var string: String {
        didSet {
            needsDisplay = true
        }
    }

    override func keyDown(with event: NSEvent) {
        let isReturnKey = event.keyCode == 36 || event.keyCode == 76
        let isShiftPressed = event.modifierFlags.contains(.shift)

        if isReturnKey && !isShiftPressed {
            submitHandler?()
            return
        }

        super.keyDown(with: event)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard string.isEmpty else {
            return
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.placeholderTextColor,
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize)
        ]

        let rect = NSRect(x: 5, y: 12, width: bounds.width - 10, height: 20)
        placeholder.draw(in: rect, withAttributes: attributes)
    }
}
