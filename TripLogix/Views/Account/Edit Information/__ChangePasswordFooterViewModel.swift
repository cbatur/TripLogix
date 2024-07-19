
import Foundation
import Combine

class ChangePasswordFooterViewModel: ObservableObject {
    @Published var actionResponse: TLResponse?
    @Published var actionLoading: Bool = false
    
    private var apiService = TLAPIService()
    private var cancellables: Set<AnyCancellable> = []
    
    func processPasswordChange(email: String, oldPassword: String, password: String) {
        self.actionResponse = nil
        self.actionLoading = true
        self.apiService.processPasswordChange(email: email, oldPassword: oldPassword, password: password)
            .catch {_ in Just(TLResponse(message: "Network error", success: false)) }
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                print("[Debug] \(response)")
                self?.actionResponse = response
                self?.actionLoading = false
            })
            .store(in: &cancellables)
    }

}
