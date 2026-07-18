import SwiftUI

struct TipListView: View {
    let category: TipCategory
    @Environment(TipDatabase.self) private var tipDB

    var body: some View {
        List {
            ForEach(tipDB.tips(for: category)) { tip in
                TipRow(tip: tip)
            }
        }
        .navigationTitle(category.rawValue)
    }
}

struct TipCategoriesView: View {
    @Environment(TipDatabase.self) private var tipDB
    @State private var searchText = ""

    private var searchResults: [CatTip] {
        tipDB.searchTips(searchText)
    }

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    ForEach(TipCategory.allCases) { category in
                        NavigationLink(value: category) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text(category.rawValue)
                                        .font(.body.bold())
                                    Text("\(tipDB.tips(for: category).count) tips")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.pink)
                            }
                        }
                    }
                } else if searchResults.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(searchResults) { tip in
                        TipRow(tip: tip, showsCategory: true)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search all tips...")
            .navigationTitle("All Tips")
            .navigationDestination(for: TipCategory.self) { category in
                TipListView(category: category)
            }
        }
    }
}

struct TipRow: View {
    let tip: CatTip
    var showsCategory = false
    @Environment(TipDatabase.self) private var tipDB

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tip.title)
                    .font(.headline)
                Spacer()
                ShareLink(item: tip.shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Share tip")
                Button {
                    tipDB.toggleFavorite(tip.id)
                } label: {
                    Image(systemName: tipDB.isFavorite(tip.id) ? "heart.fill" : "heart")
                        .foregroundStyle(tipDB.isFavorite(tip.id) ? .pink : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tipDB.isFavorite(tip.id) ? "Remove from saved tips" : "Save tip")
            }
            Text(tip.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if showsCategory {
                Label(tip.category.rawValue, systemImage: tip.icon)
                    .font(.caption.bold())
                    .foregroundStyle(.pink)
            }
        }
        .padding(.vertical, 4)
    }
}
