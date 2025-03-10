
import Foundation

enum QCategory {
    case getDailyPlan(city: String, dateRange: String, tripsExtension: String)
    case getVenueDetails(location: String)
    case getAllEvents(city: String, dateRange: String)
    case textFromImageUrl(imageUrl: String)
    case getEventCategories(city: String)
    case getFlightDetails(query: String)

    var title: String {
        switch self {
        case .getDailyPlan(let city, let dateRange, _):
            return "Itinerary for \(city) between \(dateRange)"
        case .getVenueDetails(let location):
            return "Venue Infiormation \(location)"
        case .getAllEvents(let city, let dateRange):
            return "All events for \(city) between \(dateRange)"
        case .textFromImageUrl(let imageUrl):
            return "Flight info from \(imageUrl)"
        case .getEventCategories(let city):
            return "Event Categories for \(city)"
        case .getFlightDetails(let query):
            return "Flight info from \(query)"
        }
    }
    
    var chatDescription: String {
        switch self {
        case .getDailyPlan(let city, let dateRange, let tripsExtension):
            return "Make a travel plan for \(city) between dates \(dateRange), in a json format using the following format " + dailyPlanExtension + tripsExtension
        case .getVenueDetails(let location):
            return "\(location) " + venueInformationExtension
        case .getAllEvents(let city, let dateRange):
            return "Generate a list of events to do in \(city), for dates \(dateRange)" + allEvents
        case .textFromImageUrl:
            return createFlightParametersFromImage
        case .getEventCategories(let city):
            return "List 20 activity categories that apply to \(city), return in an array format as [String]"
        case .getFlightDetails(let query):
            return query + " " + flightInfoModel
        }
    }
    
    var content: String {
        return "\(chatDescription)"
    }
}

func appendJsonModel(_ filename: String) -> String {
    guard let fileURL = Bundle.main.url(forResource: "\(filename)", withExtension: "json") else {
        print("Failed to locate the JSON file.")
        return ""
    }
    
    do {
        
        let jsonData = try Data(contentsOf: fileURL)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else { return "" }
    } catch {
        return ""
    }
}

public let allEvents = " group them by category such as art, nature, sports, dining, entertainment, festival, event. Add as many places to visit like parks, amusement centers, historic places as possible. Return the response in json format with a String key as 'category' with the value category and a key named events as a string array as the events. List it for visitors to make a travel plan, do not list a category If it has no values.  Use the format { category: '', events: [] }"

public let dailyPlanExtension = "return in an array of json object of title with key named 'title', and a key named 'date' with the date of the particular day with format 'yyyy-MM-dd', and a key named index for the order as Integer, and a key named 'activities' as [Activity], where Activity has a key named googlePlaceId as an empty string, a key named title for title and a key named index for the order as Integer and categories as category of activity as a string array such as, restaurant, sports, checkin, checkout, drive, train, bus, art, nature, museum, nightlife etc. Provide the response as a plain array of objects, without and explinatory text, the 'json' keyword, backticks, or any additional formatting. The response should be in a format to be serialized."

public let venueInformationExtension = "return as a json object of keys venueName and venueDescription as string, also city, country as Strings and locationName in a format to be searched for geolocation."

public let createFlightParametersFromImage = "Analyze this image and return the list of flight infos in a json format to be serialized as an array of the following object. Please provide the flight information as a plain array of objects, without the 'json' keyword, backticks, or any additional formatting. Just the raw array is needed. -> a key named iataCode as String as the 3 letter departure airport iata code, a key named type as String to be hardcoded to departure, a key named date as String as the departure date formatted 2024-01-01, a key named destinationIataCode as String as the 3 letter arrival airport iata code"

let flightInfoModel = "Provide the response in the following JSON format: {\"flight_number\": \"SA322\", \"airline\": \"Saudi Arabian Airlines\", \"departure_airport\": {\"name\": \"King Abdulaziz International Airport\", \"iata_code\": \"JED\", \"city\": \"Jeddah\", \"country\": \"Saudi Arabia\"}, \"arrival_airport\": {\"name\": \"Heathrow Airport\", \"iata_code\": \"LHR\", \"city\": \"London\", \"country\": \"United Kingdom\"}, \"scheduled_departure\": \"2025-05-30T01:44:00+00:00\", \"scheduled_arrival\": \"2025-05-30T06:00:00+00:00\", \"flight_duration\": \"5h 16m\", \"aircraft\": {\"model\": \"Boeing 787-9\"}}"

let flightInfoModel2 = """
{
  \"flight_number\": \"[Flight_Number_1]\",
  \"airline\": \"[Airline_Name]\",
  \"departure_airport\": {
    \"name\": \"[Departure_Airport_Name]\",
    \"iata_code\": \"[IATA_Code]\",
    \"city\": \"[City]\",
    \"country\": \"[Country]\"
  },
  \"arrival_airport\": {
    \"name\": \"[Arrival_Airport_Name]\",
    \"iata_code\": \"[IATA_Code]\",
    \"city\": \"[City]\",
    \"country\": \"[Country]\"
  },
  \"scheduled_departure\": \"[YYYY-MM-DDTHH:MM:SS±TZ:00]\",
  \"scheduled_arrival\": \"[YYYY-MM-DDTHH:MM:SS±TZ:00]\",
  \"flight_duration\": \"[Xh Ym]\",
  \"aircraft\": {
    \"model\": \"[Aircraft_Model]\"
  }
}
"""

let flightInfoModels = """
{
  "flights": [
    {
      "flight_number": "[Flight_Number_1]",
      "airline": "[Airline_Name]",
      "departure_airport": {
        "name": "[Departure_Airport_Name]",
        "iata_code": "[IATA_Code]",
        "city": "[City]",
        "country": "[Country]"
      },
      "arrival_airport": {
        "name": "[Arrival_Airport_Name]",
        "iata_code": "[IATA_Code]",
        "city": "[City]",
        "country": "[Country]"
      },
      "scheduled_departure": "[YYYY-MM-DDTHH:MM:SS±TZ:00]",
      "scheduled_arrival": "[YYYY-MM-DDTHH:MM:SS±TZ:00]",
      "flight_duration": "[Xh Ym]",
      "aircraft": {
        "model": "[Aircraft_Model]"
      }
    },
    {
      "layover": {
        "location": "[Airport_Name] ([IATA_Code])",
        "duration": "[Xh Ym]"
      }
    },
    {
      "flight_number": "[Flight_Number_2]",
      "airline": "[Airline_Name]",
      "departure_airport": {
        "name": "[Departure_Airport_Name]",
        "iata_code": "[IATA_Code]",
        "city": "[City]",
        "country": "[Country]"
      },
      "arrival_airport": {
        "name": "[Arrival_Airport_Name]",
        "iata_code": "[IATA_Code]",
        "city": "[City]",
        "country": "[Country]"
      },
      "scheduled_departure": "[YYYY-MM-DDTHH:MM:SS±TZ:00]",
      "scheduled_arrival": "[YYYY-MM-DDTHH:MM:SS±TZ:00]",
      "flight_duration": "[Xh Ym]",
      "aircraft": {
        "model": "[Aircraft_Model]"
      }
    }
  ]
}
"""


