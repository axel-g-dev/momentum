import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.textPrimary)
                    .contentTransition(.numericText())

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HStack(spacing: 16) {
        StatCardView(
            title: "Active",
            value: "5",
            systemImage: "flame.fill",
            color: .accentGreen
        )
        StatCardView(
            title: "Best Streak",
            value: "12 d",
            systemImage: "bolt.fill",
            color: .orange
        )
    }
    .padding()
}
