
import Foundation

extension OpenAIRequests {
    struct TextCommandFlight {
        
        var qType: QCategory
        var path = "chat/completions"
        
        var request: URLRequest {
            
            let path = "\(Configuration.openAI.baseUrl)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }
            
            guard let openAPIKey = decryptAPIKey(.openAI) else { preconditionFailure("Bad API Key") }
            
            let jsonString = """
            {
                "model": "\(OpenAPIModel.gpt4.rawValue)",
                "messages": [
                    {   
                        "role": "system", 
                        "content": "You are an expert at providing detailed JSON responses for flight queries." 
                    },
                    {
                        "role": "user",
                        "content": "\(qType.content.replacingOccurrences(of: "\"", with: "\\\""))"
                    }
                ]
            }
            """

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonString.data(using: .utf8)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(openAPIKey)", forHTTPHeaderField: "Authorization")
            
            return request
        }
    }
}
