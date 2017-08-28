//
//  MoyaResponseError.swift
//  Pods
//
//  Created by Levi Bostian on 8/20/17.
//
//

import Foundation
import Moya

/** 
 The error type that we return to the Moya Target's error handler in your app code.
 
 In your app's code, the Error's localizedDescription will contain the error message that your MoyaResponseHandler protocol returned. This allows you to use that as a user facing error message to help the user fix their issue.
*/
public enum MoyaResponseError: Swift.Error, LocalizedError {
    /// The user encountered a networking issue with their API request.
    case networkingError(message: String, originalError: URLError)
    /// The request was successful, but the status code is >= 300.
    case statusCodeError(message: String, statusCode: Int, request: URLRequest?, response: URLResponse?)
    /// Moya specific error. Moya had an error mapping response body to JSON, Image, String, etc.
    case moyaError(message: String, originalError: MoyaError)
    /// Not any of the URLError or Moya error types. Unknown error to the plugin.
    case otherError(message: String, originalError: Swift.Error)
    
    public var errorDescription: String? {
        switch self {
        case .networkingError(let message, _):
            return NSLocalizedString(message, comment: "No Internet, timeout, etc. Any of the URLError options.")
        case .statusCodeError(let message, _, _, _):
            return NSLocalizedString(message, comment: "Status code >= 300.")
        case .moyaError(let message, _):
            return NSLocalizedString(message, comment: "Moya specific error. Error creating Moya Endpoint, parsing JSON/Image/String, invalid status code received.")
        case .otherError(let message, _):
            return NSLocalizedString(message, comment: "Not any of the URLError options. Some other Swift.Error option.")
        }
    }
}
