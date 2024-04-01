
import Foundation
import SwiftUI

enum AlertBoxMessage {
    case analyzeImage
    case imageReceived
    case flightsTrackedInImage
    case reservationInThePast
    case imageNotSerialized
    case error
    
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
        case .error:
            return "Something Went Wrong!"
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
