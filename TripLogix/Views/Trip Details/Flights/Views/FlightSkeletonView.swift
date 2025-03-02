import SwiftUI

struct FlightSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Airline Logo Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .shimmer()

                VStack(alignment: .leading, spacing: 6) {
                    // Airline Name
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 16)
                        .shimmer()

                    // Flight Number
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 14)
                        .shimmer()
                }
                Spacer()
                
                // Selection Indicator Placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .shimmer()
            }
            .padding(.bottom, 6)

            HStack {
                VStack {
                    // Departure Time
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 16)
                        .shimmer()

                    // Departure Airport Code
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 14)
                        .shimmer()
                }
                Spacer()
                
                VStack {
                    // Duration
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 14)
                        .shimmer()
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .shimmer()
                        
                        Image(systemName: "airplane")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                Spacer()
                
                VStack {
                    // Arrival Time
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 16)
                        .shimmer()

                    // Arrival Airport Code
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 14)
                        .shimmer()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
