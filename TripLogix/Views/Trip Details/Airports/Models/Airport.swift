
import Foundation

struct AirportResponse: Codable, Hashable {
    let data: [Airport]
}

struct Airport: Codable, Hashable, Identifiable {
    var id: String { presentation.id }
    let presentation: AirportPresentation
    let navigation: Navigation
    
    struct AirportPresentation: Codable, Hashable {
        let id: String
        let title: String
        let suggestionTitle: String
        let subtitle: String
        let skyId: String
    }
    
    struct Navigation: Codable, Hashable {
        var id: String { entityId }
        let entityId: String
        let entityType: String
    }
}
