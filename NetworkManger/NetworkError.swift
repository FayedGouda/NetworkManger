
import Foundation

public enum NetworkError: String, LocalizedError{
    case errorDecoding
    case UnknownError
    case invalidUrl
    case TimeOut
    case serverError
    case serviceUnavilable
    case NotFound
    case UnsupportedMediaType
    case BadRequest
    case Unauthorized
    case InternalServerError
    public var errorDescription: String? {
        return self.rawValue
    }
}
