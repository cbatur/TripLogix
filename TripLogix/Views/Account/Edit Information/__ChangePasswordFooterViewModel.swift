
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

// Validations and non-API functions
extension ChangePasswordFooterViewModel {
    
    func isValid(name: String) -> Bool {
            // Check if name is not empty
            guard !name.isEmpty else {
                return false
            }
            
            // Check name length (e.g., minimum 2 characters, maximum 50 characters)
            guard name.count >= 2 && name.count <= 50 else {
                return false
            }
            
            // Check if name contains only valid characters (letters and spaces)
            let allowedCharacters = CharacterSet.letters.union(.whitespaces)
            let nameCharacterSet = CharacterSet(charactersIn: name)
            guard allowedCharacters.isSuperset(of: nameCharacterSet) else {
                return false
            }
            
            return true
        }
}
