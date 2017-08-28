//
//  MoyaResponseErrorHandlerProtocol.swift
//  Pods
//
//  Created by Levi Bostian on 8/26/17.
//
//

import Foundation
import Moya

/// Protocol to provide to the MoyaResponseHandlerPlugin used to return a human readable error message you can use to show to user in your app.
public protocol MoyaResponseErrorHandlerProtocol {
    
    func statusCodeError(_ statusCode: Int, request: URLRequest?, response: URLResponse?) -> String
    
    /**
     Moya network request was not successful. No network connection, bad network connection, permission error, SSL error, etc.
     
     Here is an example code snippet on how you can handle this response:
     ```
     switch error {
     case notConnectedToInternet(let error): return "You are not connected to the Internet."
     case badNetworkRequest(let error): return "There is a problem with your Internet connection. Try again."
     case cancelledRequest(let error): return ""
     case failedNetworkRequest(let error): return "There was a problem with your request. We are working on it to fix it."
     }
     ```
     
     - Returns: Human readable string meant to show to the end user about the error.
     */
    func networkingError(_ error: MoyaNetworkingError) -> String
    
    /**
     Moya error encountered. This is a Moya specific error. It could be because Moya had an error parsing the response body to JSON/Image/String. It could be an invalid status code. This is probably an error that you should fix in your app's code. It may not be a user issue.
     
     Here is an example code snippet on how you can handle this response:
     ```
     switch error {
     case imageMapping(Response)
     /// Indicates a response failed to map to a JSON structure.
     case jsonMapping(Response)
     /// Indicates a response failed to map to a String.
     case stringMapping(Response)
     /// Indicates a response failed with an invalid HTTP status code.
     case statusCode(Response)
     /// Indicates a response failed due to an underlying `Error`.
     case underlying(Swift.Error)
     /// Indicates that an `Endpoint` failed to map to a `URLRequest`.
     case requestMapping(String)
     }
     ```
     
     - Returns: Human readable string meant to show to the end user about the error.
     */
    func moyaError(_ error: MoyaError) -> String
    
    /**
     Error that is not a URLError or Moya error. It is an unknown error that you should handle yourself. Not sure why this would ever happen in your code, but something happened.
     
    - Returns: Human readable string meant to show to the end user about the error.
     */
    func unknownError(_ error: Swift.Error) -> String
}
