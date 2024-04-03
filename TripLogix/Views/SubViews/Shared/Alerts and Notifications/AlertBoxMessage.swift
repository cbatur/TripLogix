
import Foundation
import SwiftUI

enum AlertBoxMessage: Equatable {
    case analyzeImage
    case imageReceived
    case flightsTrackedInImage
    case reservationInThePast
    case imageNotSerialized
    case error(String)
    case dayTripInitial(String)
    case dayTripInitial2
    case dayTripInitial3(String)
    
    var systemImage: String {
        switch self {
        case .analyzeImage:
            return "text.below.photo.fill"
        case .imageReceived:
            return "airplane"
        case .flightsTrackedInImage:
            return "info.bubble"
        case .reservationInThePast:
            return "square.and.arrow.up.trianglebadge.exclamationmark"
        case .imageNotSerialized:
            return "exclamationmark.triangle"
        case .error:
            return "exclamationmark.triangle"
        case .dayTripInitial:
            return "cablecar"
        case .dayTripInitial2:
            return "fork.knife.circle"
        case .dayTripInitial3:
            return "cloud.hail"
        }
    }
    
    var message: String {
        switch self {
        case .analyzeImage:
            return "Trying to understand your image!!!"
        case .imageReceived:
            return "Got your image, let's see If we can pull your flight info..."
        case .flightsTrackedInImage:
            return "Perfect. We tracked some flights, now fetching the details."
        case .reservationInThePast:
            return "The reservation for this ticket is in the past; please ensure it is for a future flight."
        case .imageNotSerialized:
            return "Flight info could not be read the image. Try again or upload another image."
        case .error(let message):
            return "\(message)"
        case .dayTripInitial(let city):
            return "SIT TIGHT \nWe're building the perfect itinerary for \(city)"
        case .dayTripInitial2:
            return "This is taking a while because we're looking up everything. \n\nYou're in good hands."
        case .dayTripInitial3(let city):
            return "There are lots of exciting places to do in \(city) \n\nWe're brushing up the details."
        }
    }
    
    var startAnimate: Bool {
        switch self {
        case .analyzeImage:
            return true
        case .imageReceived:
            return true
        case .flightsTrackedInImage:
            return true
        case .reservationInThePast:
            return false
        case .imageNotSerialized:
            return false
        case .error:
            return false
        case .dayTripInitial:
            return true
        case .dayTripInitial2:
            return true
        case .dayTripInitial3:
            return true
        }
    }
}

struct AlertWithIconView: View {
    @State private var isRotating: Bool = false
    @State private var rotationDegrees: Double = 0
    var alertBox: AlertBoxMessage
    
    var body: some View {
        HStack {
            Image(systemName: alertBox.systemImage)
                .font(.largeTitle)
                .foregroundColor(.wbPinkMedium)
                .rotationEffect(.degrees(rotationDegrees))
                .onAppear {
                    startOrStopAnimation()
                }
                .onChange(of: alertBox.startAnimate) { _, _ in
                    startOrStopAnimation()
                }
            Text(alertBox.message)
                .font(.custom("Gilroy-Medium", size: 16))
                .foregroundColor(.black.opacity(0.8))
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .cardStyle(.gray.opacity(0.1))
    }
    
    private func startOrStopAnimation() {
        if alertBox.startAnimate {
            // Reset the rotation degrees to start the animation again if it was stopped.
            rotationDegrees = 0
            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotationDegrees = 360
            }
            isRotating = true
        } else {
            // Stop the animation by not repeating it and allowing it to complete its current cycle.
            withAnimation(Animation.linear(duration: 1)) {
                rotationDegrees = 0
            }
            isRotating = false
        }
    }
}
