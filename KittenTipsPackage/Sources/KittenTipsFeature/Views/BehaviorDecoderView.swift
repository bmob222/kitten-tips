import SwiftUI

struct BehaviorDecoderView: View {
    @State private var searchText = ""

    private var filteredBehaviors: [BehaviorSign] {
        if searchText.isEmpty {
            return TipDatabase.behaviorSigns
        }
        return TipDatabase.behaviorSigns.filter {
            $0.behavior.localizedCaseInsensitiveContains(searchText)
            || $0.meaning.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBehaviors) { sign in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: sign.icon)
                                .foregroundStyle(moodColor(sign.mood))
                                .frame(width: 24)
                            Text(sign.behavior)
                                .font(.headline)
                            Spacer()
                            Text(sign.mood.capitalized)
                                .font(.caption2.bold())
                                .foregroundStyle(moodColor(sign.mood))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(moodColor(sign.mood).opacity(0.15))
                                .clipShape(Capsule())
                        }
                        Text(sign.meaning)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .searchable(text: $searchText, prompt: "Search behaviors...")
            .navigationTitle("Behavior Decoder")
        }
    }

    private func moodColor(_ mood: String) -> Color {
        switch mood {
        case "happy": .green
        case "anxious": .orange
        case "angry": .red
        case "sick": .purple
        case "playful": .blue
        case "relaxed": .mint
        default: .secondary
        }
    }
}
