import SwiftUI

struct BreedPickerView: View {
    @Environment(BreedLibrary.self) private var library
    @Environment(StreakTracker.self) private var streak
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(KittenBreed.all) { breed in
                        BreedRow(
                            breed: breed,
                            isSelected: library.selected.id == breed.id,
                            isUnlocked: library.isUnlocked(breed, longestStreak: streak.longestStreak),
                            longestStreak: streak.longestStreak
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if library.select(breed, longestStreak: streak.longestStreak) {
                                dismiss()
                            }
                        }
                    }
                } header: {
                    Text("Unlock new kittens by keeping your streak alive")
                        .font(.caption)
                        .textCase(nil)
                }
            }
            .navigationTitle("Your Kittens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct BreedRow: View {
    let breed: KittenBreed
    let isSelected: Bool
    let isUnlocked: Bool
    let longestStreak: Int

    var body: some View {
        HStack(spacing: 14) {
            Text(breed.emoji)
                .font(.system(size: 40))
                .frame(width: 56, height: 56)
                .background(.pink.opacity(isUnlocked ? 0.12 : 0.04))
                .clipShape(Circle())
                .grayscale(isUnlocked ? 0 : 0.9)
                .opacity(isUnlocked ? 1 : 0.5)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(breed.name)
                        .font(.headline)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.pink)
                    }
                }
                Text(breed.tagline)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !isUnlocked {
                    Label("Unlock at \(breed.unlockStreak)-day streak", systemImage: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
