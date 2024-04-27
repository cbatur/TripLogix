
import Foundation

extension OpenAIRequests {
    struct TextCommand4 {
        
        var qType: QCategory
        var path = "chat/completions"
        
        init(qType: QCategory, path: String = "chat/completions") {
            self.qType = qType
            self.path = path
        }
        
        var request: URLRequest {
            
            let path = "\(Configuration.openAI.baseUrl)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }
            
            guard let openAPIKey = decryptAPIKey(.openAI) else { preconditionFailure("Bad API Key") }
            
            let postData = """
                {
                    "model": "\(OpenAPIModel.textDavinci004.rawValue)",
                    "prompt": "\(qType.content)", 
                        "max_tokens": 150,
                        "temperature": 0.5
                }
                """

            var request = URLRequest(url: url ,timeoutInterval: Double.infinity)
            request.httpMethod = "POST"
            request.httpBody = postData.data(using: .utf8)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(openAPIKey)", forHTTPHeaderField: "Authorization")
            
            return request
        }
    }
}
