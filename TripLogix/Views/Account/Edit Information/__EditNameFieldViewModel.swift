
import Foundation
import Combine

class EditNameFieldViewModel: ObservableObject {
    @Published var message: String?
    @Published var success: Bool = false
    
    private var apiService = TLAPIService()
    private var cancellables: Set<AnyCancellable> = []
    
    func updateNameField(tablename: String, itemvalue: String, userid: String) {
        self.message = "Loading"
        self.success = false
        self.apiService.updateColumn(
            tablename: tablename,
            itemvalue: itemvalue,
            userid: userid
        )
            .catch {_ in Just(UserResponse(message: "")) }
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                print("[Debug] \(response)")
                if let user = response.data {
                    SessionManager.shared.createSession(for: user)
                    self?.message = "Name updated"
                    self?.success = true
                } else {
                    self?.message = "Something Went Wrong"
                    self?.success = false
                }
            })
            .store(in: &cancellables)
    }

}

// Validations and non-API functions
extension EditNameFieldViewModel {
    
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
