//
//  MoyaResponseHandlerPlugin.swift
//  Pods
//
//  Created by Levi Bostian on 8/20/17.
//
//

import Foundation
import Moya
import Result

/**
 
 Enable/disable running the MoyaResponseHandlerPlugin for Moya Target. Inherit this protocol in your Moya TargetType enum and override the functions.
 
*/
protocol RunMoyaResponseHandlerProtocol {
    
    /// Enable or disable running the MoyaResponseHandler plugin code on this target. true is used by default.
    var enableMoyaResponseHandlerPlugin: Bool { get }
}

/// Protocol used to handle the Moya network request from the MoyaResponseHandlerPlugin.
public protocol MoyaResponseHandler {
    /** 
      The Moya network request was successful (HTTP request successful with status code >= 200 and < 300). You may not need to do anything here, but it is here in case you want to run some code after a successful API request.
    */
    func successfulResponse(_ target: TargetType, statusCode: Int, data: Data, request: URLRequest, response: URLResponse)
    
    /**
      Moya network request was successful, but a HTTP status code was returned >= 300. 
     
     switch statusCode {
     case 401: return "You must login to do that action."
     case 403: return "You do not have permission to do that action."
     case >= 500: return "System is currently down. Try again later."
     }
     
     *The error message you return from this function could be used as user facing. Please, make sure to use good error messages to the user that are helpful to them in fixing the problem.*
     
     - Returns: Return back a string that should be used as the Moya request error handler's Error localizedDescription.
     */
    func statusCodeError(_ target: TargetType, statusCode: Int, data: Data, request: URLRequest, response: URLResponse?) -> String
    
    /**
     Moya network request was not successful. No network connection, bad network connection, permission error, SSL error, etc.
     
     switch error {
     case notConnectedToInternet(let error): return "You are not connected to the Internet."
     case badNetworkRequest(let error): return "There is a problem with your Internet connection. Try again."
     case cancelledRequest(let error): return ""
     case failedNetworkRequest(let error): return "There was a problem with your request. We are working on it to fix it."
     }
     
     *The error message you return from this function could be used as user facing. Please, make sure to use good error messages to the user that are helpful to them in fixing the problem.*
     
     - Returns: Return back a string that should be used as the Moya request error handler's Error localizedDescription.
     */
    func networkingError(_ target: TargetType, error: MoyaNetworkingError, request: URLRequest?, response: URLResponse?) -> String
    
    /**
     Moya error encountered. This is a Moya specific error. It could be because Moya had an error parsing the response body to JSON/Image/String. It could be an invalid status code. This is probably an error that you should fix in your app's code. It may not be a user issue.
     
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
     
     *The error message you return from this function could be used as user facing. Please, make sure to use good error messages to the user that are helpful to them in fixing the problem.*
     
     - Returns: Return back a string that should be used as the Moya request error handler's Error localizedDescription.
     */
    func moyaError(_ target: TargetType, error: MoyaError) -> String
    
    /**
     Error that is not a URLError or Moya error. It is an unknown error that you should handle yourself. Not sure why this would ever happen in your code, but something happened.
     
     *The error message you return from this function could be used as user facing. Please, make sure to use good error messages to the user that are helpful to them in fixing the problem.*
     
     - Returns: Return back a string that should be used as the Moya request error handler's Error localizedDescription.
     */
    func unknownError(_ target: TargetType, error: Swift.Error) -> String
}

/**
 
 Moya plugin that handles Moya responses before completion handler is called. The plugin will take the response, see if it was successful or failed and allow developer to quickly and easily handle the response in a nice API.
 
 To use, provide the plugin to your MoyaProvider constructor: `MoyaProvider<Target>(plugins: [MoyaResponseHandlerPlugin(handler: MyMoyaResponseHandler)])`
 
 */
public class MoyaResponseHandlerPlugin: PluginType {
    
    private let handler: MoyaResponseHandler
    
    /// Provide the MoyaResponseHandlerPlugin with your code to be executed after each Moya network request.
    public init(handler: MoyaResponseHandler) {
        self.handler = handler
    }
    
    public final func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        if let target = target as? RunMoyaResponseHandlerProtocol, !target.enableMoyaResponseHandlerPlugin {
            return result
        }
        
        let apiRequest: URLRequest? = result.value?.request
        let apiResponse: URLResponse? = result.value?.response
        
        return result.analysis(ifSuccess: { (moyaResponse: Response) -> Result<Response, MoyaError> in
            let statusCode = result.value!.statusCode
            
            switch statusCode {
            case 200...299:
                handler.successfulResponse(target, statusCode: statusCode, data: moyaResponse.data, request: apiRequest!, response: apiResponse!)
                return result
            default:
                let errorMessage: String = handler.statusCodeError(target, statusCode: statusCode, data: moyaResponse.data, request: apiRequest!, response: apiResponse)
                
                return Result.failure(MoyaError.underlying(MoyaResponseError.statusCodeError(message: errorMessage, statusCode: statusCode, request: apiRequest, response: apiResponse)))
            }
        }) { (responseError: MoyaError) -> Result<Response, MoyaError> in
            switch responseError {
            case MoyaError.imageMapping, MoyaError.jsonMapping, MoyaError.requestMapping, MoyaError.statusCode, MoyaError.stringMapping:
                let errorMessage: String = handler.moyaError(target, error: responseError)
                
                return Result.failure(MoyaError.underlying(MoyaResponseError.moyaError(message: errorMessage, originalError: responseError, request: apiRequest, response: apiResponse)))
            case MoyaError.underlying(let error):
                if let urlError = error as? URLError {
                    var errorMessage = ""
                    
                    switch urlError.code {
                    case URLError.Code.notConnectedToInternet:
                        errorMessage = handler.networkingError(target, error: MoyaNetworkingError.notConnectedToInternet(urlError), request: apiRequest, response: apiResponse)
                        break
                    case URLError.Code.timedOut, URLError.Code.networkConnectionLost, URLError.Code.dnsLookupFailed:
                        errorMessage = handler.networkingError(target, error: MoyaNetworkingError.badNetworkRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    case URLError.Code.cancelled:
                        errorMessage = handler.networkingError(target, error: MoyaNetworkingError.cancelledRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    default:
                        errorMessage = handler.networkingError(target, error: MoyaNetworkingError.failedNetworkRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    }
                    return Result.failure(MoyaError.underlying(MoyaResponseError.networkingError(message: errorMessage, originalError: urlError, request: apiRequest, response: apiResponse)))
                } else {
                    let errorMessage: String = handler.unknownError(target, error: responseError)
                    
                    return Result.failure(MoyaError.underlying(MoyaResponseError.otherError(message: errorMessage, originalError: error, request: apiRequest, response: apiResponse)))
                }
            }
        }
    }
    
}
