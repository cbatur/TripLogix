
import Foundation
import SwiftUI

//extension FlightManageView {
//    
//    var analyticsFlightSearchParams: [String: Any] {
//        return [
//            "departure_codeIataAirport": departureCity?.codeIataAirport ?? "",
//            "departure_codeIataCity": departureCity?.codeIataCity ?? "",
//            "departure_nameAirport": departureCity?.nameAirport ?? "",
//            "departure_nameCountry": departureCity?.nameCountry ?? "",
//            "arrival_codeIataAirport": arrivalCity?.codeIataAirport ?? "",
//            "arrival_codeIataCity": arrivalCity?.codeIataCity ?? "",
//            "arrival_nameAirport": arrivalCity?.nameAirport ?? "",
//            "arrival_nameCountry": arrivalCity?.nameCountry ?? "",
//            "flight_date": formatDateDisplay(flightDate)
//        ]
//    }
//}

extension TripDetailsView {
    var tripDetailsViewAppearParams: [String: Any] {
        return [
            "destination_city": "\(destination.name)"
        ]
    }
}
