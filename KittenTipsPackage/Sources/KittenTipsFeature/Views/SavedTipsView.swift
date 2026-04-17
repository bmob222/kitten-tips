import SwiftUI

struct SavedTipsView: View {
    @Environment(TipDatabase.self) private var tipDB

    var body: some View {
        NavigationStack {
            Group {
                if tipDB.favoriteTips.isEmpty {
                    ContentUnavailableView {
                        Label("No Saved Tips", systemImage: "heart.slash")
                    } description: {
                        Text("Tap the heart on any tip to save it here.")
                    }
                } else {
                    List {
                        ForEach(tipDB.favoriteTips) { tip in
                            TipRow(tip: tip)
                        }
                    }
                }
            }
            .navigationTitle("Saved Tips")
        }
    }
}
