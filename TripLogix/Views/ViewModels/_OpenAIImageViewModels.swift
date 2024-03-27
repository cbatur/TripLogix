
import Combine
import Foundation

final class _OpenAIImageViewModels: ObservableObject {
    
    @Published var flights: [EventCategory] = []

    private var apiService = OpenAIAPIService()
    private var cancellable: AnyCancellable?

//    func executeVenueService(
//        qType: QCategory,
//        location: String
//    ) {
//        self.loadingMessage = self.activityMessage.content
//        self.cancellable = self.apiService.openAPIGetDailyPlan(qType: qType)
//            .catch {_ in Just(ChatGPTResponse(id: "0", choices: [])) }
//            .sink(receiveCompletion: { _ in }, receiveValue: {
//                guard let questionSet = $0.choices.first?.message.content else { return }
//                self.fetchRandomLocationPhoto(keyword: location)
//
//                if let jsonData = questionSet.data(using: .utf8) {
//                    do {
//                        let item = try JSONDecoder().decode(VenueInfo.self, from: jsonData)
//
//                        self.venueInfo = item
//                        self.loadingMessage = nil
//                    } catch {
//                        //self.getDailyitinerary(qType: qType)
//                        print("Error deserializing JSON: \(error)")
//                    }
//                }
//            })
//    }
    
}


