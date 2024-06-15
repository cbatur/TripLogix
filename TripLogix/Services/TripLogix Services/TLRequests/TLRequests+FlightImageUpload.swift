
import Foundation
  
extension TLRequests {
    struct FlightImageUpload {
        
        var imageString: String
        var imageName: String
        var path = "TempFlightImages/uploadTempImage.php?id="
        
        var request: URLRequest {
            let path = "\(Configuration.TripLogix.baseUrlTemp)\(path)\(imageName)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }
            
            let paramStr: String = "image=\(imageString)"
            let paramData: Data = paramStr.data(using: .utf8) ?? Data()
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Cpntent-Type")
            request.httpBody = paramData
            
            return request
        }
    }
}
