import SwiftUI

struct FlightResultsCardView: View {
    let id: String
    let airlineName: String
    let flightNumber: String
    let airlineImageName: String
    let departureTime: String
    let departureAirport: String
    let duration: String
    let arrivalTime: String
    let arrivalAirport: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: airlineImageName)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 32, height: 32)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .cornerRadius(16)

                        case .failure(_):
                            Image(systemName: "smallcircle.filled.circle")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .cornerRadius(16)

                        @unknown default:
                            EmptyView()
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(airlineName)
                            .foregroundStyle(.black)
                            .font(.headline)
                        Text(flightNumber)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(
                                isSelected ? Color.blue : Color.gray.opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 24, height: 24)

                        if isSelected {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
            }
            .padding(.bottom, 6)

            HStack {
                VStack {
                    Text(departureTime)
                        .foregroundStyle(.black)
                        .font(.headline)
                    Text(departureAirport)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack {
                    Text(duration)
                        .font(.caption)
                        .foregroundColor(.gray)
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 2)
                        Image(systemName: "airplane")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                    }
                }
                Spacer()
                VStack {
                    Text(arrivalTime)
                        .foregroundStyle(.black)
                        .font(.headline)
                    Text(arrivalAirport)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onSelect()
        }
    }
}
