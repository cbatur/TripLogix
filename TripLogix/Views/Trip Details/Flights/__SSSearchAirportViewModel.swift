import Combine
import Foundation

final class SearchAirportViewModel: ObservableObject {

    @Published var query = ""
    @Published var globalSSAirports: [SSAirport] = []
    
    private let apiHost = Configuration.SkyScrapper.apiHost
    private var cancellableSet: Set<AnyCancellable> = []
    private let ssAPIService = SkyScrapperAPIService()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Adds a debounce to limit requests
            .removeDuplicates() // Avoids sending a request if the search text hasn't changed
            .filter { $0.count > 2 } // Only sends a request if the search text has more than 2 characters
            .flatMap { query in
                self.fetchAirportsPublisher(query: query)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            }, receiveValue: { [weak self] airports in
                self?.globalSSAirports = airports.data
            })
            .store(in: &cancellableSet)
    }
    
    private func fetchAirportsPublisher(query: String) -> AnyPublisher<SSAirportResponse, Error> {
        guard let url = URL(string: "https://\(Configuration.SkyScrapper.apiHost)/flights/auto-complete?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        guard let apiKey = decryptAPIKey(.skyScrapper) else { preconditionFailure("Bad API Key") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(apiHost, forHTTPHeaderField: "X-RapidAPI-Host")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SSAirportResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func searchAirport(_ city: String) -> AnyPublisher<[SSAirport], SSError> {
        guard city.count == 3 else {
            return Just([]).setFailureType(to: SSError.self).eraseToAnyPublisher()
        }

        return ssAPIService.airportSearch(city: city)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
