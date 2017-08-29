//
//  Error+Extensions.swift
//  Pods
//
//  Created by Levi Bostian on 8/28/17.
//
//

import Foundation
import Moya

public extension Swift.Error {
    
    private func errorHandlerNotSet() {
        fatalError("You did not provide an error handler for Lucid.")
    }
    
    /// Take the error that Moya returned to you after performing the networking request to get a better, human readable error message `LucidMoyaResponseError`.
    public func getLucidError(errorHandler: LucidMoyaResponseErrorProtocol? = Singleton.sharedInstance.errorHandler) -> Swift.Error {
        guard let errorHandler = errorHandler else {
            errorHandlerNotSet()
            return LucidMoyaResponseError.moyaError(message: "this should never run", originalError: self as! MoyaError)
        }
        
        if let moyaError = self as? MoyaError {
            switch moyaError {
            case MoyaError.statusCode(let response):
                let errorMessage = errorHandler.statusCodeError(response.statusCode, request: response.request, response: response.response)
                
                return LucidMoyaResponseError.statusCodeError(message: errorMessage, statusCode: response.statusCode, request: response.request, response: response.response)
            case MoyaError.imageMapping, MoyaError.jsonMapping, MoyaError.requestMapping, MoyaError.stringMapping:
                let errorMessage = errorHandler.moyaError(moyaError)
                
                return LucidMoyaResponseError.moyaError(message: errorMessage, originalError: moyaError)
            case MoyaError.underlying(let error):
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case URLError.Code.notConnectedToInternet:
                        let errorMessage = errorHandler.networkingError(LucidMoyaNetworkingError.notConnectedToInternet(urlError))
                        
                        return LucidMoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    case URLError.Code.timedOut, URLError.Code.networkConnectionLost, URLError.Code.dnsLookupFailed:
                        let errorMessage = errorHandler.networkingError(LucidMoyaNetworkingError.badNetworkRequest(urlError))
                        
                        return LucidMoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    case URLError.Code.cancelled:
                        let errorMessage = errorHandler.networkingError(LucidMoyaNetworkingError.cancelledRequest(urlError))
                        
                        return LucidMoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    default:
                        let errorMessage = errorHandler.networkingError(LucidMoyaNetworkingError.failedNetworkRequest(urlError))
                        
                        return LucidMoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    }
                } else {
                    // return self so we allow any custom errors thrown to be passed through.
                    return self
                }
            }
        } else {
            // return self so we allow any custom errors thrown (instead of MoyaErrors) to be passed through.
            return self
        }
    }
    
}
