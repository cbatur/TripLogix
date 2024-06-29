import Foundation
import Combine

class EmailVerificationFooterViewModel: ObservableObject {
    
    @Published var resendResponse: TLResponse?
    @Published var resendLoading: Bool = false
    @Published var verificationResponse: TLResponse?
    @Published var verificationLoading: Bool = false

    private var apiService = TLAPIService()
    private var cancellables: Set<AnyCancellable> = []
    
    func setVerificationCode(email: String) {
        self.resendResponse = nil
        self.verificationResponse = nil
        self.resendLoading = true
        self.apiService.setVerificationCode(email: email)
            .catch {_ in Just(TLResponse(message: "Network error", success: false)) }
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.resendResponse = response
                self?.resendLoading = false
            })
            .store(in: &cancellables)
    }
    
    func verifyAccount(email: String, access_code: String) {
        self.resendResponse = nil
        self.verificationResponse = nil
        self.verificationLoading = true
        self.apiService.verifyUser(email: email, access_code: access_code)
            .catch {_ in Just(TLResponse(message: "Network error", success: false)) }
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.verificationResponse = response
                self?.resendLoading = false
                self?.verificationLoading = false
            })
            .store(in: &cancellables)
    }

}

// Validations and non-API functions
extension EmailVerificationFooterViewModel {
    
    func isCodeValid(_ code: String) -> Bool {
        guard !code.isEmpty else {
            return false
        }
        
        guard code.count == 4 else {
            return false
        }

        return true
    }
}
