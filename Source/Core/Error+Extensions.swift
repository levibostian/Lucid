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
        fatalError("You forgot to construct the MoyaResponseErrorHandlerPlugin with an instance of a default errorHandler instance or provide an instance of errorHandler into response function.")
    }
    
    /// Take the error that Moya returned to you after performing the networking request to get a better, human readable error message `MoyaResponseError`.
    public func getMoyaResponseError(errorHandler: MoyaResponseErrorHandlerProtocol? = Singleton.sharedInstance.errorHandler) -> MoyaResponseError {
        guard let errorHandler = errorHandler else {
            errorHandlerNotSet()
            return MoyaResponseError.otherError(message: "this should never run", originalError: self)
        }
        
        if let moyaError = self as? MoyaError {
            switch moyaError {
            case MoyaError.statusCode(let response):
                let errorMessage = errorHandler.statusCodeError(response.statusCode, request: response.request, response: response.response)
                
                return MoyaResponseError.statusCodeError(message: errorMessage, statusCode: response.statusCode, request: response.request, response: response.response)
            case MoyaError.imageMapping, MoyaError.jsonMapping, MoyaError.requestMapping, MoyaError.stringMapping:
                let errorMessage = errorHandler.moyaError(moyaError)
                
                return MoyaResponseError.moyaError(message: errorMessage, originalError: moyaError)
            case MoyaError.underlying(let error):
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case URLError.Code.notConnectedToInternet:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.notConnectedToInternet(urlError))
                        
                        return MoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    case URLError.Code.timedOut, URLError.Code.networkConnectionLost, URLError.Code.dnsLookupFailed:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.badNetworkRequest(urlError))
                        
                        return MoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    case URLError.Code.cancelled:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.cancelledRequest(urlError))
                        
                        return MoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    default:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.failedNetworkRequest(urlError))
                        
                        return MoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    }
                } else {
                    let errorMessage = errorHandler.unknownError(error)
                    
                    return MoyaResponseError.otherError(message: errorMessage, originalError: error)
                }
            default:
                let errorMessage = errorHandler.unknownError(moyaError)
                return MoyaResponseError.otherError(message: errorMessage, originalError: moyaError)
            }
        } else {
            let errorMessage = errorHandler.unknownError(self)
            return MoyaResponseError.otherError(message: errorMessage, originalError: self)
        }
    }
    
}
