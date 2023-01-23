//
//  test.swift
//  NetworkManger
//
//  Created by ProjectEgy on 19/01/2023.
//

import Foundation

open class Test{
    public init() {
        print("New")
    }
    
    func fayed(){
        
    }
//    private func request<T: Decodable>(route: Route, method: HttpMethod, parameters: JSON? = nil, isAuthorizedRequest:Bool? = false,
//                                     completion: @escaping(Result<T, Error>) -> Void) {
//            guard let request = createRequest(route: route, method: method, isAuthorizedRequest:isAuthorizedRequest, parameters: parameters) else {
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            var result: Result<Data, Error>?
//            if let data = data {
//                let responseString = String(data: data, encoding: .utf8) ?? "Could not stringify our data"
//                    print("The response is:\n\(responseString)")
//            }
//
//            if let errorStatus = ResponseHandler.shared.handleResponseErrors(response: response, error: error){
//                result = .failure(errorStatus)
//            }else{
//                if let error = error {
//                    result = .failure(error)
//                }
//            }
//
//            if let data = data {
//                result = .success(data)
//            }
//
//            DispatchQueue.main.async{
//                ResponeDecoder.shared.decodeResponse(result: result, completion: completion)
//            }
//        }.resume()
//    }
    
    public func createRequest(route: String,
                       method: HttpMethod,
                       parameters: JSON? = nil) -> URLRequest? {
        
        let url = URL(string: route)
        guard let url = url else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer ", forHTTPHeaderField: "Authorization")
           
        if let params = parameters {
            print(params)
            switch method {
            case .get, .delete:
                var urlComponent = URLComponents(string: route)
                urlComponent?.queryItems = params.map { URLQueryItem(name: $0, value: "\($1)") }
                urlRequest.url = urlComponent?.url
             
            case .post, .patch, .put:
                let bodyData = try? JSONSerialization.data(withJSONObject: params, options: [])
                urlRequest.httpBody = bodyData
            }
        }
        return urlRequest
    }
    
//    func handleResponseErrors(response:URLResponse?, error:Error?) ->LocalizedError?{
//
//        if let error = error {
//            if (error as? URLError)?.code == .timedOut {
//                return NetworkError.TimeOut
//            }else{
//                return error as? LocalizedError
//            }
//        }
//
//        if let responseStatusCode = response as? HTTPURLResponse{
//            switch responseStatusCode.statusCode{
//            case 503:
//                return NetworkError.serverError
//            case 401:
//                return NetworkError.Unauthorized
//            default:
//                break
//            }
//        }
//        return "" as? LocalizedError
//    }
}
