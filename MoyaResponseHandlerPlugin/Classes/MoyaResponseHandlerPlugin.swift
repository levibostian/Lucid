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

protocol RunMoyaResponseHandlerProtocol {
    var enableMoyaResponseHandlerPlugin: Bool { get }
}

public protocol MoyaResponseHandler {
    func successfulResponse(statusCode: Int, data: Data, request: URLRequest, response: URLResponse)
    func statusCodeError(statusCode: Int, data: Data, request: URLRequest, response: URLResponse?) -> String
    func networkingError(error: MoyaNetworkingError, request: URLRequest?, response: URLResponse?) -> String
    func moyaError(error: MoyaError) -> String
    func unknownError(error: Swift.Error) -> String
}

public class MoyaResponseHandlerPlugin: PluginType {
    
    private let handler: MoyaResponseHandler
    
    public init(handler: MoyaResponseHandler) {
        self.handler = handler
    }
    
    public func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        if let target = target as? RunMoyaResponseHandlerProtocol, !target.enableMoyaResponseHandlerPlugin {
            return result
        }
        
        let apiRequest: URLRequest? = result.value?.request
        let apiResponse: URLResponse? = result.value?.response
        
        return result.analysis(ifSuccess: { (moyaResponse: Response) -> Result<Response, MoyaError> in
            let statusCode = result.value!.statusCode
            
            switch statusCode {
            case 200...299:
                handler.successfulResponse(statusCode: statusCode, data: moyaResponse.data, request: apiRequest!, response: apiResponse!)
                return result
            default:
                let errorMessage: String = handler.statusCodeError(statusCode: statusCode, data: moyaResponse.data, request: apiRequest!, response: apiResponse)
                
                return Result.failure(MoyaError.underlying(MoyaResponseError.statusCodeError(message: errorMessage)))
            }
        }) { (responseError: MoyaError) -> Result<Response, MoyaError> in
            switch responseError {
            case MoyaError.imageMapping, MoyaError.jsonMapping, MoyaError.requestMapping, MoyaError.statusCode, MoyaError.stringMapping:
                let errorMessage: String = handler.moyaError(error: responseError)
                
                return Result.failure(MoyaError.underlying(MoyaResponseError.moyaError(message: errorMessage)))
            case MoyaError.underlying(let error):
                if let urlError = error as? URLError {
                    var errorMessage = ""
                    
                    switch urlError.code {
                    case URLError.Code.notConnectedToInternet:
                        errorMessage = handler.networkingError(error: MoyaNetworkingError.notConnectedToInternet(urlError), request: apiRequest, response: apiResponse)
                        break
                    case URLError.Code.timedOut, URLError.Code.networkConnectionLost, URLError.Code.dnsLookupFailed:
                        errorMessage = handler.networkingError(error: MoyaNetworkingError.badNetworkRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    case URLError.Code.cancelled:
                        errorMessage = handler.networkingError(error: MoyaNetworkingError.cancelledRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    default:
                        errorMessage = handler.networkingError(error: MoyaNetworkingError.failedNetworkRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    }
                    return Result.failure(MoyaError.underlying(MoyaResponseError.networkingError(message: errorMessage)))
                } else {
                    let errorMessage: String = handler.unknownError(error: responseError)
                    
                    return Result.failure(MoyaError.underlying(MoyaResponseError.otherError(message: errorMessage)))
                }
            }
        }
    }
    
}
