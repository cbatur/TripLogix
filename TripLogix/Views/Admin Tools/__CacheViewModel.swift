
import Combine
import Foundation

struct CacheItem: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    let name: String
    let content: String
    var date: Date = Date()
    
}
final class CacheViewModel: ObservableObject {
    
    @Published var cachedItems: [CacheItem] = []
    
    func getCachedItems() {
        self.cachedItems = []
        if let savedObjects = UserDefaults.standard.object(forKey: "cachedItems") as? Data {
            let decoder = JSONDecoder()
            if let loadedObjects = try? decoder.decode([CacheItem].self, from: savedObjects) {
                self.cachedItems = loadedObjects
                removeOlderGooglePlaces()
            } else { return }
        } else { return }
    }
    
    func removeOlderGooglePlaces() {
        // Keeps the last 200 records, removes the older ones.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(self.cachedItems.prefix(200))) {
            UserDefaults.standard.set(encoded, forKey: "cachedItems")
        }
    }
    
    // Cache Item
    func addCachedItem(_ c: CacheItem) {
        getCachedItems()
        
        if !self.cachedItems.contains(where: {
            $0.id == c.id
        }) {
            self.cachedItems.append(c)
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.cachedItems) {
            UserDefaults.standard.set(encoded, forKey: "cachedItems")
        }
    }
}
