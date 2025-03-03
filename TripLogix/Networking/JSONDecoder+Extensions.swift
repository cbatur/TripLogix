
import Foundation

/// Provides a standardized `JSONDecoder` for consistent decoding across the app
extension JSONDecoder {
    
    /// Default API decoder with common settings
    static var apiDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    /// Custom decoder for APIs that use different date formats
    static func customDecoder(dateFormat: String) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }
}
