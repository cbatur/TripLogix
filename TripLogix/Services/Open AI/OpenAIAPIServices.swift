
import Foundation
import Combine

enum OpenAPIModel: String {
    case gpt35Turbo = "gpt-3.5-turbo"
    case gpt4VisionPreview = "gpt-4-vision-preview"
}

struct OpenAIAPIError: Codable, Error {
    let error: OpenAIAPIErrorType
    
    init(error: OpenAIAPIErrorType) {
        self.error = error
    }
}

struct OpenAIAPIErrorType: Codable, Error {
    let message: String
    let type: String?
    let param: String?
    let code: String?
    
    init(message: String) {
        self.message = message
        self.type = nil
        self.param = nil
        self.code = nil
    }
}

protocol OpenAIServiceProvider {
    func openAPICommand(qType: QCategory) -> AnyPublisher<ChatGPTResponse, OpenAIAPIError>
    func openAPIGenerateImage(keyword: String) -> AnyPublisher<ChatGPTImageResponse, OpenAIAPIError>
    func openAPICommand4(qType: QCategory) -> AnyPublisher<ChatGPTResponse, OpenAIAPIError>
}

class OpenAIAPIService: OpenAIServiceProvider {

    private func apiCall<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, OpenAIAPIError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { _ in OpenAIAPIError(error: OpenAIAPIErrorType(message: "Server Error")) }
            .map { $0.data }
            .print()
            .decode(type: T.self, decoder: JSONDecoder())
            .print()
            .mapError { _ in OpenAIAPIError(error: OpenAIAPIErrorType(message: "Parsing Error")) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func openAPICommand(qType: QCategory) -> AnyPublisher<ChatGPTResponse, OpenAIAPIError> {
        return self.apiCall(OpenAIRequests.TextCommand(qType: qType).request)
    }

    func openAPIGenerateImage(keyword: String) -> AnyPublisher<ChatGPTImageResponse, OpenAIAPIError> {
        return self.apiCall(OpenAIRequests.ImageCreate(keyword: keyword).request)
    }
    
    func openAPICommand4(qType: QCategory) -> AnyPublisher<ChatGPTResponse, OpenAIAPIError> {
        return self.apiCall(OpenAIRequests.RemoteImageToText(qType: qType).request)
    }
}

