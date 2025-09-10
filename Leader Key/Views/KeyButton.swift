import AppKit
import SwiftUI

typealias KeyChangedFn = ((_ before: String?, _ value: String?) -> Void)

struct KeyButton: View {
  @Binding var text: String
  let placeholder: String
  @State private var isListening = false
  @State private var oldValue = ""
  var validationError: ValidationErrorType? = nil
  var onKeyChanged: KeyChangedFn? = nil

  var body: some View {
    Button(action: {
      oldValue = text
      isListening = true
    }) {
      Text(text.isEmpty ? placeholder : (KeyMaps.glyph(for: text) ?? text))
        .frame(width: 32, height: 24)
        .background(
          RoundedRectangle(cornerRadius: 5)
            .fill(backgroundColor)
            .overlay(
              RoundedRectangle(cornerRadius: 5)
                .stroke(borderColor, lineWidth: 1)
            )
        )
        .foregroundColor(text.isEmpty ? .gray : .primary)
    }
    .buttonStyle(PlainButtonStyle())
    .background(
      KeyListenerView(
        isListening: $isListening, text: $text, oldValue: $oldValue, onKeyChanged: onKeyChanged))
  }

  private var backgroundColor: Color {
    if isListening {
      return Color.blue.opacity(0.3)
    } else if validationError != nil {
      return Color.red.opacity(0.1)
    } else {
      return Color(.controlBackgroundColor)
    }
  }

  private var borderColor: Color {
    if isListening {
      return Color.clear
    } else if validationError != nil {
      return Color.red
    } else {
      return Color.gray.opacity(0.5)
    }
  }
}

struct KeyListenerView: NSViewRepresentable {
  @Binding var isListening: Bool
  @Binding var text: String
  @Binding var oldValue: String
  var onKeyChanged: KeyChangedFn?

  func makeNSView(context: Context) -> NSView {
    let view = KeyListenerNSView()
    view.isListening = $isListening
    view.text = $text
    view.oldValue = $oldValue
    view.onKeyChanged = onKeyChanged
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {
    if let view = nsView as? KeyListenerNSView {
      view.isListening = $isListening
      view.text = $text
      view.oldValue = $oldValue
      view.onKeyChanged = onKeyChanged

      if isListening {
        DispatchQueue.main.async {
          view.window?.makeFirstResponder(view)
        }
      }
    }
  }

  class KeyListenerNSView: NSView {
    var isListening: Binding<Bool>?
    var text: Binding<String>?
    var oldValue: Binding<String>?
    var onKeyChanged: KeyChangedFn?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
    }

    override func keyDown(with event: NSEvent) {
      guard let isListening = isListening, let text = text, isListening.wrappedValue else {
        super.keyDown(with: event)
        return
      }

      // Handle special behaviors first
      switch event.keyCode {
      case 53:  // Escape key - restore old value
        if let oldValue = oldValue {
          text.wrappedValue = oldValue.wrappedValue
        }
        return
      case 51, 117:  // Backspace or Delete - clear field
        text.wrappedValue = ""
        return
      default:
        break
      }

      // Use centralized key mapping for all other keys
      if let entry = KeyMaps.entry(for: event.keyCode) {
        text.wrappedValue = entry.glyph
      } else if let characters = event.characters, !characters.isEmpty {
        // Fallback for unmapped keys
        text.wrappedValue = String(characters.first!)
      }

      DispatchQueue.main.async {
        isListening.wrappedValue = false
        self.onKeyChanged?(self.oldValue?.wrappedValue, self.text?.wrappedValue)
      }
    }

    override func resignFirstResponder() -> Bool {
      if let isListening = isListening, isListening.wrappedValue {
        DispatchQueue.main.async {
          isListening.wrappedValue = false
          self.onKeyChanged?(self.oldValue?.wrappedValue, self.text?.wrappedValue)
        }
      }
      return super.resignFirstResponder()
    }
  }
}

#Preview {
  struct Container: View {
    @State var text = "a"
    @StateObject var userConfig = UserConfig()

    var body: some View {
      VStack(spacing: 20) {
        KeyButton(
          text: $text,
          placeholder: "Key"
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: .duplicateKey
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: .emptyKey
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: .nonSingleCharacterKey
        )
        Text("Current value: '\(text)'")
      }
      .padding()
      .frame(width: 300)
      .environmentObject(userConfig)
    }
  }

  return Container()
}
