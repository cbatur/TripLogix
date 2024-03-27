
import Foundation

extension OpenAIRequests {
    struct ImageCreate {
        
        var keyword: String
        var path = "images/generations"
        
        var request: URLRequest {
            let path = "\(Configuration.openAI.baseUrl)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }
            
            let title = ["keyword": keyword]
            
            let jsonString = """
            {
                "prompt": "\(title)",
                "n": 1,
                "size": "512x512"
              }
            """

            guard let openAPIKey = decryptAPIKey(.openAI) else { preconditionFailure("Bad API Key") }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonString.data(using: .utf8)
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(openAPIKey)", forHTTPHeaderField: "Authorization")
            
            print(request.prettyDescription)
            return request
        }
    }
}
