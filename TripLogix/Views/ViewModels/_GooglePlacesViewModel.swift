
import Foundation
import Combine

class GooglePlacesViewModel: ObservableObject {
    @Published var photosData: [String] = []
    private var cancellables = Set<AnyCancellable>()
    

    
    // Get Photos By Places Id

    // Function to fetch place details using Google Places API
    func fetchPlaceDetails(placeId: String) {
        
        guard let apiKey = decryptAPIKey(.googlePlaces) else { preconditionFailure("Bad API Key") }
        
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                //completion(.failure(error))
                return
            }

            guard let data = data else {
                //completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            if let photoReferences = self.extractPhotoReferences(from: data) {
                // Here you would fetch the actual photos using the photo references
                // Typically this involves constructing a URL with the photo reference and your API key
                // Then you can use this URL to load the image, e.g., in an UIImageView
                self.photosData = photoReferences
            }
            
            //completion(.success(data))
        }

        task.resume()
    }

    // Function to parse place details and extract photo references
    func extractPhotoReferences(from data: Data) -> [String]? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let dictionary = jsonObject as? [String: Any],
                  let result = dictionary["result"] as? [String: Any],
                  let photos = result["photos"] as? [[String: Any]] else { return nil }

            guard let apiKey = decryptAPIKey(.googlePlaces) else { preconditionFailure("Bad API Key") }
            
            return photos.compactMap {
                "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=\($0["photo_reference"] ?? "")&key=\(apiKey)" as? String

                //$0["photo_reference"] as? String
            }
            
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }

    // Example usage
//    let placeId = "YOUR_PLACE_ID"
//    fetchPlaceDetails(placeId: placeId) { result in
//        switch result {
//        case .success(let data):
//            if let photoReferences = extractPhotoReferences(from: data) {
//                // Here you would fetch the actual photos using the photo references
//                // Typically this involves constructing a URL with the photo reference and your API key
//                // Then you can use this URL to load the image, e.g., in an UIImageView
//            }
//        case .failure(let error):
//            print("Error fetching place details: \(error)")
//        }
//    }

}

// Model for Google Places response

