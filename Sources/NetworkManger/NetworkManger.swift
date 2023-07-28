
import Foundation
import Alamofire

public typealias RequestHeaders = [String:String]
public typealias JSON = [String:Any]

public protocol TargetType{
    ///Http meth such as GET, POST
    var httpMethod:HttpMethod { get }
    ///Path to your api ex:api.your_domain.com/api/users
    var endPoint:String { get }
    
    var isAuthorizedRequrest:Bool  { get }

    var headers:[String:String]? { get }
    
    var encoding:ParameterEncoding { get }
}


open class BaseAPI<T:TargetType> {
    
    private var isConnectedToInternet:Bool {
            return NetworkReachabilityManager()?.isReachable ?? false
        }
    
    ///Base URL for your project
    ///You can have multiple base urls in the same project, in this case add a baseUrl { get } property
    ///to TargetType Protocol
    open var baseUrl:String = ""
    
    public init() {
        
    }
    
    public func request<M: Codable>(for target:T, parameters:JSON? = nil, completion: @escaping(Result<M, Error>) -> Void){
        
        guard isConnectedToInternet else {
            completion(.failure(NetworkError.NoInternetConnection))
            return
        }
        
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
                
                guard let responseObj = response.value else {
                    completion(.failure(NetworkError.errorDecoding))
                    return
                }
                
                completion(.success(responseObj))
                
            }
        }
    }
    
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
