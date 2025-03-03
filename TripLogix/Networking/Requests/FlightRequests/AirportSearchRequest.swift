
import Foundation

extension FlightRequests {
    struct AirportSearch {
        var city: String

        var endpoint: Endpoint {
            let apiHost = Configuration.SkyScrapper.apiHost

            var components = URLComponents()
            components.scheme = "https"
            components.host = apiHost

            guard let apiKey = decryptAPIKey(.skyScrapper) else { preconditionFailure("Bad API Key") }

            components.queryItems = [
                URLQueryItem(name: "query", value: city)
            ]

            return Endpoint(
                service: .flights,
                baseURL: "https://\(apiHost)",
                path: "/flights/auto-complete",
                method: .GET,
                queryItems: components.queryItems,
                headers: [
                    "X-RapidAPI-Host": apiHost,
                    "X-RapidAPI-Key": apiKey
                ]
            )
        }
    }
}
