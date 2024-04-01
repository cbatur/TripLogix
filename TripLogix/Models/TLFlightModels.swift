
import Foundation

struct SelectedFlight {
    var id: String = UUID().uuidString
    var date: Date = Date()
    let flight: AEFutureFlight
    var selected: Bool? = nil
}

struct SelectedFlightGroup: Decodable, Hashable {
    var id: String = UUID().uuidString
    var date: Date = Date()
    let flights: [AEFutureFlight]
}
