
import Foundation

extension OpenAIRequests {
    struct RemoteImageToText {
        
        var qType: QCategory
        var path = "chat/completions"
        var url = ""
        
        init(qType: QCategory, path: String = "chat/completions") {
            self.qType = qType
            self.path = path
            if case .textFromImageUrl(let imageUrl) = qType {
                self.url = imageUrl
            }
        }
        
        var request: URLRequest {
            
            let path = "\(Configuration.openAI.baseUrl)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }
            
            guard let openAPIKey = decryptAPIKey(.openAI) else { preconditionFailure("Bad API Key") }
            
            let postData = """
            {
                "model": "\(OpenAPIModel.gpt4VisionPreview.rawValue)",
                "messages": [
                    {
                        "role": "user",
                        "content": [
                          {
                            "type": "text",
                            "text": "What’s in this image?"
                          },
                          {
                            "type": "image_url",
                            "image_url": {
                              "url": "\(self.url)"
                            }
                          }
                        ]
                    }
                ]
            }
            """

            var request = URLRequest(url: url ,timeoutInterval: Double.infinity)
            request.httpMethod = "POST"
            request.httpBody = postData.data(using: .utf8)
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(openAPIKey)", forHTTPHeaderField: "Authorization")
            
            print(request.prettyDescription)
            return request
        }
    }
}
