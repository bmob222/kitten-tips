import SwiftUI

struct KittenAgeGuideView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(KittenAge.allCases) { age in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "pawprint.fill")
                                    .foregroundStyle(.pink)
                                Text(age.rawValue)
                                    .font(.headline.bold())
                                Spacer()
                            }

                            ForEach(age.milestones, id: \.self) { milestone in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                        .padding(.top, 2)
                                    Text(milestone)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Kitten Age Guide")
        }
    }
}
