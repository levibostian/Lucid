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

internal class Configuration {
    
    internal var errorHandler: MoyaResponseErrorHandlerProtocol?
    internal var logger: MoyaResponseLogger?
    
    static let sharedInstance = Configuration()
    
    private init() {
    }
}

/**
 Moya plugin that logs the Moya API network response before completion handler is called. 
 
 To use, provide the plugin to your MoyaProvider constructor: `MoyaProvider<Target>(plugins: [MoyaResponseHandlerPlugin(logger: MyMoyaResponseLogger())])`
 */
public class MoyaResponseHandlerPlugin: PluginType {
    
    /// Provide the MoyaResponseHandlerPlugin with your logger instance if you wish.
    public init(errorHandler: MoyaResponseErrorHandlerProtocol, logger: MoyaResponseLogger?) {
        Configuration.sharedInstance.errorHandler = errorHandler
        Configuration.sharedInstance.logger = logger
    }
    
    public final func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        let apiRequest: URLRequest? = result.value?.request
        let apiResponse: URLResponse? = result.value?.response
        
        return result.analysis(ifSuccess: { (moyaResponse: Response) -> Result<Response, MoyaError> in
            Configuration.sharedInstance.logger?.successfulResponse(target, statusCode: result.value!.statusCode, data: moyaResponse.data, request: apiRequest!, response: apiResponse!)
            
            return result
        }) { (responseError: MoyaError) -> Result<Response, MoyaError> in
            switch responseError {
            case MoyaError.imageMapping, MoyaError.jsonMapping, MoyaError.requestMapping, MoyaError.statusCode, MoyaError.stringMapping:
                Configuration.sharedInstance.logger?.moyaError(target, error: responseError, request: apiRequest, response: apiResponse)
            case MoyaError.underlying(let error):
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case URLError.Code.notConnectedToInternet:
                        Configuration.sharedInstance.logger?.networkingError(target, error: MoyaNetworkingError.notConnectedToInternet(urlError), request: apiRequest, response: apiResponse)
                        break
                    case URLError.Code.timedOut, URLError.Code.networkConnectionLost, URLError.Code.dnsLookupFailed:
                        Configuration.sharedInstance.logger?.networkingError(target, error: MoyaNetworkingError.badNetworkRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    case URLError.Code.cancelled:
                        Configuration.sharedInstance.logger?.networkingError(target, error: MoyaNetworkingError.cancelledRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    default:
                        Configuration.sharedInstance.logger?.networkingError(target, error: MoyaNetworkingError.failedNetworkRequest(urlError), request: apiRequest, response: apiResponse)
                        break
                    }
                } else {
                    Configuration.sharedInstance.logger?.unknownError(target, error: responseError, request: apiRequest, response: apiResponse)
                }
            }
            return Result.failure(responseError)
        }
    }
    
}
