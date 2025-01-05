import Foundation
import SwiftData

// ---------------- Aviation Edge Data ------------------
@Model
class DSelectedFlight: Hashable {
    var id: String = "\(Int(Date().timeIntervalSince1970))"
    var date: Date = Date()
    var flight: DFutureFlight
    
    init(date: Date, flight: DFutureFlight) {
        self.date = date
        self.flight = flight
    }

    static func == (lhs: DSelectedFlight, rhs: DSelectedFlight) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class DFutureFlight: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var weekday: String
    var departure: DAirportDetail
    var arrival: DAirportDetail
    var aircraft: DAircraft
    var airline: DAirline
    var flight: DFlight
    
    init(weekday: String, departure: DAirportDetail, arrival: DAirportDetail, aircraft: DAircraft, airline: DAirline, flight: DFlight) {
        self.weekday = weekday
        self.departure = departure
        self.arrival = arrival
        self.aircraft = aircraft
        self.airline = airline
        self.flight = flight
    }
    
    static func == (lhs: DFutureFlight, rhs: DFutureFlight) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


@Model
class DAirline: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var name: String
    var iataCode: String
    var icaoCode: String

    init(name: String, iataCode: String, icaoCode: String) {
        self.name = name
        self.iataCode = iataCode
        self.icaoCode = icaoCode
    }
    
    static func == (lhs: DAirline, rhs: DAirline) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


@Model
class DAirportDetail: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var iataCode: String
    var icaoCode: String
    var terminal: String
    var gate: String
    var scheduledTime: String

    init(iataCode: String, icaoCode: String, terminal: String, gate: String, scheduledTime: String) {
        self.iataCode = iataCode
        self.icaoCode = icaoCode
        self.terminal = terminal
        self.gate = gate
        self.scheduledTime = scheduledTime
    }

    static func == (lhs: DAirportDetail, rhs: DAirportDetail) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class DAircraft: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var modelCode: String
    var modelText: String

    init(modelCode: String, modelText: String) {
        self.modelCode = modelCode
        self.modelText = modelText
    }
    
    static func == (lhs: DAircraft, rhs: DAircraft) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class DFlight: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var number: String
    var iataNumber: String
    var icaoNumber: String
    
    init(number: String, iataNumber: String, icaoNumber: String) {
        self.number = number
        self.iataNumber = iataNumber
        self.icaoNumber = icaoNumber
    }
    
    static func == (lhs: DFlight, rhs: DFlight) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
