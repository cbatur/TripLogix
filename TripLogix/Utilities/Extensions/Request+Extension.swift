
import Foundation

extension URLRequest {
    var prettyDescription: String {
        var output = "----- URLRequest Start -----\n"
        
        if let httpMethod = httpMethod {
            output += "HTTP Method: \(httpMethod)\n"
        }
        
        if let url = url {
            output += "URL: \(url.absoluteString)\n"
        }
        
        if let allHTTPHeaderFields = allHTTPHeaderFields {
            output += "Headers:\n"
            for (key, value) in allHTTPHeaderFields {
                output += "- \(key): \(value)\n"
            }
        }
        
        if let httpBody = httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            output += "Body:\n\(bodyString)\n"
        }
        
        output += "----- URLRequest End -----\n"
        return output
    }
}
