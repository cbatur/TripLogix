//import Foundation
import Combine

//class DeleteAccountViewModel: ObservableObject {
//    
//    @Published var resendResponse: TLResponse?
//    @Published var resendLoading: Bool = false
//    @Published var verificationResponse: TLResponse?
//    @Published var verificationLoading: Bool = false
//
//    private var apiService = TLAPIService()
//    private var cancellables: Set<AnyCancellable> = []
//    
//    func setVerificationCode(email: String) {
//        self.resendResponse = nil
//        self.verificationResponse = nil
//        self.resendLoading = true
//        self.apiService.setVerificationCode(email: email)
//            .catch {_ in Just(TLResponse(message: "Network error", success: false)) }
//            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
//                self?.resendResponse = response
//                self?.resendLoading = false
//            })
//            .store(in: &cancellables)
//    }
//    
//
//
//}

// Validations and non-API functions
//extension DeleteAccountViewModel {
//    
////    func initializeVerificationFocus() {
////        isVerificationFocused = true
////    }
//
//    
////    func isCodeValid(_ code: String) -> Bool {
////        guard !code.isEmpty else {
////            return false
////        }
////        
////        guard code.count == 4 else {
////            return false
////        }
////
////        return true
////    }
//}
