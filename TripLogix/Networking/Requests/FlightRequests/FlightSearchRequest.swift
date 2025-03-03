import Foundation

extension FlightRequests {
    struct FlightSearch {
        let date: String
        let d: String
        let a: String

        var endpoint: Endpoint {
            let apiHost = Configuration.SkyScrapper.apiHost // ✅ Store once

            var components = URLComponents()
            components.scheme = "https"
            components.host = apiHost

            guard let apiKey = decryptAPIKey(.skyScrapper) else { preconditionFailure("Bad API Key") }

            components.queryItems = [
                URLQueryItem(name: "fromEntityId", value: self.d),
                URLQueryItem(name: "toEntityId", value: self.a),
                URLQueryItem(name: "departDate", value: self.date)
            ]

            return Endpoint(
                service: .flights,
                baseURL: "https://\(apiHost)", // ✅ Use variable instead of repeating
                path: "/flights/search-one-way",
                method: .GET,
                queryItems: components.queryItems,
                headers: [
                    "X-RapidAPI-Host": apiHost, // ✅ Use variable here too
                    "X-RapidAPI-Key": apiKey
                ]
            )
        }
    }
}
