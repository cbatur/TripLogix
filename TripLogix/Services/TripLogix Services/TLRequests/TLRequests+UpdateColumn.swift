
import Foundation

extension TLRequests {
    struct UpdateColumn {

        var tablename: String
        var itemvalue: String
        var userid: String
        var path = "user/update_column.php"
        
        var request: URLRequest {
            
            let path = "\(Configuration.TripLogix.baseURL)\(path)"
            guard let url = URL(string: path) else { preconditionFailure("Bad URL") }

            var body = ["tablename": tablename,
                        "itemvalue": itemvalue,
                        "userid": userid]
            body["accessToken"] = Configuration.accessToken

            guard let postData = try? JSONSerialization.data(withJSONObject: body) else {
                fatalError("Invalid Body")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        }
    }
}
