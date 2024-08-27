
import Foundation
import SwiftData

struct HotelReservation: Codable {
    let reservationId: String
    let reservationType: ReservationType
    let guest: Guest
    let property: Property
    let checkIn: CheckInOut
    let checkOut: CheckInOut
    let totalPrice: Price
    let paymentStatus: PaymentStatus
    let specialRequests: [String]?
    let cancellationPolicy: CancellationPolicy?

    enum ReservationType: String, Codable {
        case hotel
        case airbnb
    }

    enum PaymentStatus: String, Codable {
        case paid
        case pending
        case canceled
    }
    
    struct Guest: Codable {
        let firstName: String
        let lastName: String
        let email: String
        let phone: String
    }
    
    struct Property: Codable {
        let name: String
        let address: Address
        let type: ReservationType
        let rooms: [Room]
        
        struct Address: Codable {
            let street: String
            let city: String
            let state: String
            let postalCode: String
            let country: String
        }
        
        struct Room: Codable {
            let roomId: String
            let type: String
            let beds: [Bed]
            let amenities: [String]
            
            struct Bed: Codable {
                let bedType: String
                let quantity: Int
            }
        }
    }
    
    struct CheckInOut: Codable {
        let date: String
        let time: String
    }
    
    struct Price: Codable {
        let amount: Double
        let currency: String
    }
    
    struct CancellationPolicy: Codable {
        let type: CancellationType
        let details: String
        
        enum CancellationType: String, Codable {
            case flexible
            case moderate
            case strict
        }
    }
}
