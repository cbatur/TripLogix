import Foundation

@MainActor
final class CPDashBoardViewModel: ObservableObject {
    
    @Published var users: [TLUser] = []

    func submitQuery() async {
        do {
            let users = try await fetchDataset(query: "SELECT * FROM users ORDER BY loginDate DESC")
            
            await MainActor.run {
                self.users = users
            }
        } catch {
            await MainActor.run {
                print("[Debug] Failed to fetch data: \(error.localizedDescription)")
            }
        }
    }

    func fetchDataset(query: String) async throws -> [TLUser] {
        let request = AdminTLRequests.DynamicRead(query: query).request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([TLUser].self, from: data)
    }

}

