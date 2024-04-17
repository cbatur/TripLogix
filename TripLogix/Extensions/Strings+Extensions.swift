
import Foundation

extension String {
    func sanitizeOptions() -> String {
        
        var sanitized = self.replacingOccurrences(of: "A. ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "B. ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "C. ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "D. ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "A) ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "B) ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "C) ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "D) ", with: "")
        
        return sanitized
    }
    
    func sanitizeMarks() -> String {
        var sanitized = self.replacingOccurrences(of: ". ", with: "")
        sanitized = sanitized.replacingOccurrences(of: ", ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "? ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "¿ ", with: "")
        sanitized = sanitized.replacingOccurrences(of: "! ", with: "")
        return sanitized
    }
    
    func searchSanitized() -> String {
        let sanitized = self.replacingOccurrences(of: " ", with: "+")
        return sanitized
    }
}

extension String {
    func capitalizedFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
}

extension String {
    func sanitizeLocation() -> String {
        
        ////  Mark - Example usages
        //// -----------------------------------------------------
        ///print(sanitizeLocation(input: "Rome, Italy"))            // "Rome, Italy"
        ////print(sanitizeLocation(input: "43432 Rome, Italy"))      // "Rome, Italy"
        ////print(sanitizeLocation(input: "Rome, Vicinity, Italy"))  // "Rome, Italy"
        ////------------------------------------------------------
        
        // Split the input string by commas to separate the components
        var parts = self.components(separatedBy: ",")
        
        // Remove leading and trailing spaces from each part
        parts = parts.map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Check the number of parts and handle accordingly
        if parts.count == 3 {
            // Drop the middle part if there are three components
            parts.remove(at: 1)
        }
        
        // Remove any numeric characters from each part before joining them back
        let sanitizedParts = parts.map { part in
            part.components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet.punctuationCharacters))
                .joined()
                .trimmingCharacters(in: .whitespaces)
        }
        
        // Join the sanitized parts with a comma and a space
        let result = sanitizedParts.joined(separator: ", ")
        
        return result
    }
}
