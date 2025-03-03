import SwiftUI

struct NoFlightsFoundView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplayaudio.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.6))

            Text("No flights found")
                .font(.headline)
                .foregroundColor(.gray)

            Text("We couldn't find any flights matching your search. Try adjusting your search criteria.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 40)
    }
}
