import SwiftUI

struct DailyTipView: View {
    @Environment(TipDatabase.self) private var tipDB
    @Environment(StreakTracker.self) private var streakTracker
    @State private var showBreedPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if streakTracker.currentStreak > 0 {
                        StreakBadge(
                            currentStreak: streakTracker.currentStreak,
                            longestStreak: streakTracker.longestStreak
                        )
                    }

                    // Hero card
                    let tip = tipDB.tipOfTheDay
                    VStack(spacing: 16) {
                        Image(systemName: "cat.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.pink)
                            .padding(.top, 20)

                        Text("Today's Tip")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(2)

                        Text(tip.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)

                        Text(tip.body)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        HStack {
                            Label(tip.category.rawValue, systemImage: tip.icon)
                                .font(.caption.bold())
                                .foregroundStyle(.pink)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.pink.opacity(0.15))
                                .clipShape(Capsule())

                            Spacer()

                            Button {
                                tipDB.toggleFavorite(tip.id)
                            } label: {
                                Image(systemName: tipDB.isFavorite(tip.id) ? "heart.fill" : "heart")
                                    .foregroundStyle(tipDB.isFavorite(tip.id) ? .pink : .secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .pink.opacity(0.2), radius: 10, y: 5)

                    // Quick categories
                    Text("Browse by Category")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(TipCategory.allCases) { category in
                            NavigationLink(value: category) {
                                VStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .font(.title2)
                                    Text(category.rawValue)
                                        .font(.caption.bold())
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .tint(.primary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Kitten Tips")
            .navigationDestination(for: TipCategory.self) { category in
                TipListView(category: category)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBreedPicker = true
                    } label: {
                        Image(systemName: "pawprint.circle.fill")
                            .foregroundStyle(.pink)
                    }
                    .accessibilityLabel("Choose your kitten")
                }
            }
            .sheet(isPresented: $showBreedPicker) {
                BreedPickerView()
            }
        }
    }
}

private struct StreakBadge: View {
    let currentStreak: Int
    let longestStreak: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(currentStreak)-day streak")
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if longestStreak > currentStreak {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Best")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(longestStreak)")
                        .font(.headline)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current streak \(currentStreak) days. Longest streak \(longestStreak) days.")
    }

    private var subtitle: String {
        switch currentStreak {
        case 1: "Come back tomorrow to keep it going"
        case 2...6: "Whiskers is getting excited!"
        case 7...29: "You're on fire — keep it up!"
        default: "Legendary cat parent 🏆"
        }
    }
}
