import Foundation
import Combine

final class TripLogixMediaViewmodel: ObservableObject {

    @Published var loadingFlightImage: Bool = false
    @Published var flightImageUrl: String?

    private var apiService = TLAPIService()
    private var cancellable: AnyCancellable?
    
    func uploadFlightPhoto(imageUrl: String, imageString: String) {
        loadingFlightImage = true
        self.cancellable = self.apiService.flightImageUpload(
            imageUrl: imageUrl,
            imageString: imageString
        )
        .catch {_ in Just(TLImageUrl(imageUrl: "")) }
        .sink(receiveCompletion: { _ in }, receiveValue: {
            self.flightImageUrl = $0.imageUrl
            self.loadingFlightImage = false
        })
    }
    
}
