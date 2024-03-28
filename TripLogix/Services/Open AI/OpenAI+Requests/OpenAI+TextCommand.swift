
import Foundation

extension OpenAIRequests {
    struct TextCommand {
        
        var qType: QCategory
        var path = "chat/completions"
        
        var request: URLRequest {
            
            let path = "\(Configuration.openAI.baseUrl)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }
            
            guard let openAPIKey = decryptAPIKey(.openAI) else { preconditionFailure("Bad API Key") }
            
            let jsonString = """
            {
                                "model": "\(OpenAPIModel.gpt35Turbo.rawValue)",
                "messages": [
                    {
                        "role": "user",
                        "content": "\(qType.content)"
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
