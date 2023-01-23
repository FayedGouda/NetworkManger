
import Foundation
import Alamofire

public typealias RequestHeaders = [String:String]

public protocol TargetType{
    ///Http meth such as GET, POST
    var httpMethod:HttpMethod { get }
    ///Path to your api ex:api.your_domain.com/api/users
    var endPoint:String { get }
    
    var isAuthorizedRequrest:Bool  { get }

    var headers:[String:String]? { get }
    
    var encoding:ParameterEncoding { get }
}

//extension TargetType{
//    var headers:[String:String]?{
//        get {
//            return  [
//                "longitude":"\(UserDefaultHelper.shared.long ?? 31.255658)",
//                "latitude":"\(UserDefaultHelper.shared.lat ?? 30.256998)",
//                "AreaId":"\(UserDefaultHelper.shared.areaId ?? -1)"
//            ]
//        }
//    }
//}

public typealias JSON = [String:Any]
open class BaseAPI<T:TargetType> {
    
    ///Base URL for your project
    ///You can have multiple base urls in the same project, in this case add a baseUrl { get } property
    ///to TargetType Protocol
    private var baseUrl = "http://projectegy-003-site10.gtempurl.com"
    
    public init() {
        
    }
    
    public func request<M: Codable>(for target:T, parameters:JSON? = nil, completion: @escaping(Result<M, Error>) -> Void){
        
        AF.request(baseUrl + target.endPoint,
                   method:Alamofire.HTTPMethod(rawValue: target.httpMethod.rawValue),
                   parameters: parameters ?? [:],
                   encoding: target.encoding,
                   headers: HTTPHeaders(target.headers ?? [:])).responseDecodable(of: M.self) { (response) in
            
            debugPrint(response)
            
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(NetworkError.UnknownError))
                return
            }
            
            if statusCode == 200{
                guard let responseObj = response.value else {
                    completion(.failure(NetworkError.errorDecoding))
                    return
                }
                
                completion(.success(responseObj))
            }else{
                let networkError = self.handleStatusCodes(for: statusCode)
                completion(.failure(networkError))
            }
        }
    }
    
//    public func request2<M: Codable>(for target:T, parameters:JSON? = nil, completion: @escaping(Result<M, Error>) -> Void){
//        self.requestTarget = target
////        let method = Alamofire.HTTPMethod(rawValue: target.httpMethod.rawValue)
////
////        let headers = HTTPHeaders(target.headers ?? [:])
////        let params = buildParams(for: parameters)
//        let urlRequest = test.createRequest(route: "\(self.baseUrl)\(target.endPoint)", method: target.httpMethod, parameters: parameters)
//
//        AF.request(urlRequest!).responseDecodable(of: M.self) { (response) in
//            debugPrint(response)
//        }
//    }
    
    private func handleStatusCodes(for statusCode:Int)->NetworkError {
        switch statusCode{
        case 500:
            return .InternalServerError
        case 504, 502:
            return .TimeOut
        case 400:
            return .BadRequest
        case 401:
            return .Unauthorized
        case 404:
            return .NotFound
        case 415:
            return .UnsupportedMediaType
        default:
            return .UnknownError
        }
    }
}
