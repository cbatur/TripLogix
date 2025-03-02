import SwiftUI

struct AddedFlightCardView: View {
    let id: String
    let airlineName: String
    let flightNumber: String
    let airlineImageName: String
    let departureTime: String
    let departureAirport: String
    let duration: String
    let arrivalTime: String
    let arrivalAirport: String
    let arrivalAirportName: String
    let departureAirportName: String
    let onDelete: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: airlineImageName)) { phase in
                        switch phase {
                        case .empty:
                            Image(systemName: "airplane.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                            
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .cornerRadius(16)
                            
                        case .failure(_):
                            Image(systemName: "airplane")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(airlineName)
                                .font(.system(size: 16))
                                .foregroundColor(Color.slSofiColor).bold()
                            Spacer()
                            Image(systemName: "x.square")
                                .foregroundStyle(.gray.opacity(0.8))
                                .font(.system(size: 18))
                                .onTapGesture {
                                    onDelete(id)
                                }
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            Text(flightNumber)
                                .foregroundStyle(Color.black)
                                .font(.system(size: 16)).bold()
                            Spacer()
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
            
            Text("\(departureAirportName) -> \(arrivalAirportName)")
                .foregroundStyle(.black)
                .font(.system(size: 14))
                .padding(.vertical, 7)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
