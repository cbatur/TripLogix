import Foundation

extension SkyScrapperRequests {
    struct FlightSearch {
        
        var date: String
        var d: String
        var a: String
        
        var request: URLRequest {
            var components = URLComponents(string: "https://\(Configuration.SkyScrapper.apiHost)/flights/search-one-way")
            
            guard let apiKey = decryptAPIKey(.skyScrapper) else { preconditionFailure("Bad API Key") }
            
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "fromEntityId", value: self.d),
                URLQueryItem(name: "toEntityId", value: self.a),
                URLQueryItem(name: "departDate", value: self.date)
                //URLQueryItem(name: "stops", value: "direct")
            ]
            
            components?.queryItems = queryItems
            
            guard let url = components?.url else { preconditionFailure("Bad URL") }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(Configuration.SkyScrapper.apiHost, forHTTPHeaderField: "X-RapidAPI-Host")
            request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")

            return request
        }
    }
}
