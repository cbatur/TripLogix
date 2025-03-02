
import Foundation

extension SkyScrapperRequests {
    struct CitySearch {
        
        var city: String
        
        var request: URLRequest {
            var components = URLComponents(string: "https://\(Configuration.SkyScrapper.apiHost)/flights/auto-complete")
            
            guard let apiKey = decryptAPIKey(.skyScrapper) else { preconditionFailure("Bad API Key") }
            
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "query", value: city)
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
