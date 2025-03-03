
import Foundation

/// Standardized error handling for network requests
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed(DecodingError)
    case serviceError(service: APIService, error: Any) // Supports multiple services
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingFailed:
            return "Failed to decode the response."
        case .serviceError(let service, let error):
            return "Error from \(service.serviceName): \(error)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

/// Enum to define different services (Flights, TL, etc.)
enum APIService {
    case flights
    case tl
    case other(String) // For additional services

    var serviceName: String {
        switch self {
        case .flights: return "Flight Service"
        case .tl: return "TL Service"
        case .other(let name): return name
        }
    }
}
