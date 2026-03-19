import SwiftUI

struct PromptCharacterCounter: View {
    let count: Int
    let max: Int

    var body: some View {
        HStack {
            Spacer()
            Text("\(count) / \(max) characters")
                .font(.caption)
                .foregroundStyle(count > max ? .red : .secondary)
        }
    }
}
