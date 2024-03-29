import Combine
import Foundation

final class ImageToFlightViewModel: ObservableObject {
    
    @Published var flightsFromImage: [AEFutureFlightParams] = []
    @Published var textFromImage: String = ""
    
    @Published var loadingFlightImage: Bool = false
    @Published var flightImageUrl: String?

    private var openAIAPIService = OpenAIAPIService()
    private var tlAPIService = TLAPIService()
    private var cancellable: AnyCancellable?
    
    @Published var loadingMessage: String? = nil
    @Published var loadingIconMessage: String? = nil
    
    private var apiCount = 0
    private var activityMessage: ActivityIndicatorMessage = .blank
    
    func uploadFlightPhoto(imageUrl: String, imageString: String) {
        loadingFlightImage = true
        self.cancellable = self.tlAPIService.flightImageUpload(
            imageUrl: imageUrl,
            imageString: imageString
        )
        .catch {_ in Just(TLImageUrl(imageUrl: "")) }
        .sink(receiveCompletion: { _ in }, receiveValue: {
            self.flightImageUrl = $0.imageUrl
            self.loadingFlightImage = false
        })
    }
    
    func getFlightParametersFromImage(_ imageUrl: String) {
        self.loadingMessage = self.activityMessage.content
        self.cancellable = self.openAIAPIService.openAPICommand4(qType: QCategory.textFromImageUrl(imageUrl: imageUrl))
            .catch {_ in Just(ChatGPTResponse(id: "0", choices: [])) }
            .sink(receiveCompletion: { _ in }, receiveValue: {
                guard let questionSet = $0.choices.first?.message.content else { return }
                
                self.textFromImage = questionSet
                
                if let jsonData = questionSet.data(using: .utf8) {
                    do {
                        let items = try JSONDecoder().decode([AEFutureFlightParams].self, from: jsonData)
                        
                        self.flightsFromImage = items
                        self.loadingMessage = nil
                    } catch {
                        self.getFlightParametersFromImage(imageUrl)
                    }
                }
            })
    }
    
}
