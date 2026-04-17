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

    var body: some View {
        NavigationStack {
            List {
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
            }
            .navigationTitle("All Tips")
            .navigationDestination(for: TipCategory.self) { category in
                TipListView(category: category)
            }
        }
    }
}

struct TipRow: View {
    let tip: CatTip
    @Environment(TipDatabase.self) private var tipDB

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tip.title)
                    .font(.headline)
                Spacer()
                Button {
                    tipDB.toggleFavorite(tip.id)
                } label: {
                    Image(systemName: tipDB.isFavorite(tip.id) ? "heart.fill" : "heart")
                        .foregroundStyle(tipDB.isFavorite(tip.id) ? .pink : .secondary)
                }
                .buttonStyle(.plain)
            }
            Text(tip.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
