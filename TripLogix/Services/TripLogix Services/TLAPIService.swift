
import Foundation
import Combine

struct TLError: Codable, Error {
    let message: String
    let success: Bool
}

protocol ServiceProvider {
    func searchLocation(keyword: String) -> AnyPublisher<[Location], TLError>
    func flightImageUpload(imageName: String, imageString: String) -> AnyPublisher<TLImageUrl, TLError>
    func validateToken(jwt: String) -> AnyPublisher<UserResponse, TLError>
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, TLError>
    func create(username: String, email: String, password: String) -> AnyPublisher<LoginResponse, TLError>
    func checkUsernameExists(username: String) -> AnyPublisher<DataExistsCheck, TLError>
    func checkEmailExists(email: String) -> AnyPublisher<DataExistsCheck, TLError>
    func updateColumn(tablename: String, itemvalue: String, userid: String) -> AnyPublisher<UserResponse, TLError>

}

class TLAPIService: ServiceProvider {

    private func apiCall<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, TLError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { _ in TLError(message: "Response Mapping Error", success: false) }
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { _ in TLError(message: "JSON Mapping Error", success: false) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func searchLocation(keyword: String) -> AnyPublisher<[Location], TLError> {
        return self.apiCall(TLRequests.SearchGooglePlaces(keyword: keyword).request)
    }
    
    func flightImageUpload(imageName: String, imageString: String) -> AnyPublisher<TLImageUrl, TLError> {
        return self.apiCall(TLRequests.FlightImageUpload(imageString: imageString, imageName: imageName).request)
    }
    
    func validateToken(jwt: String) -> AnyPublisher<UserResponse, TLError> {
        return self.apiCall(TLRequests.ValidateToken(jwt: jwt).request)
    }

    func login(email: String, password: String) -> AnyPublisher<LoginResponse, TLError> {
        return self.apiCall(TLRequests.Login(email: email, password: password).request)
    }
    
    func create(username: String, email: String, password: String) -> AnyPublisher<LoginResponse, TLError> {
        return self.apiCall(TLRequests.CreateAccount(username: username, email: email, password: password).request)
    }
    
    func checkUsernameExists(username: String) -> AnyPublisher<DataExistsCheck, TLError> {
        return self.apiCall(TLRequests.CheckUsername(username: username).request)
    }
    
    func checkEmailExists(email: String) -> AnyPublisher<DataExistsCheck, TLError> {
        return self.apiCall(TLRequests.CheckEmailExists(email: email).request)
    }

    func updateColumn(tablename: String, itemvalue: String, userid: String) -> AnyPublisher<UserResponse, TLError> {
        return self.apiCall(TLRequests.UpdateColumn(tablename: tablename, itemvalue: itemvalue, userid: userid).request)
    }
}

