//
//  Response+Extensions.swift
//  Pods
//
//  Created by Levi Bostian on 8/26/17.
//
//

import Foundation
import Moya
import RxSwift

enum MoyaResponseHandlerFatalError: Swift.Error, LocalizedError {
    case errorHandlerNotSet
    
    public var errorDescription: String? {
        switch self {
        case .errorHandlerNotSet:
            return NSLocalizedString("You forgot to construct the MoyaResponseErrorHandlerPlugin with an instance of a default errorHandler instance or provide an instance of errorHandler into response function.", comment: "")
        }
    }
}

extension ObservableType where E == Response {
    
    private func errorProcessor<R>(response: Response, errorHandler: MoyaResponseErrorHandlerProtocol) -> (Swift.Error) throws -> Observable<R> {
        return { (error: Swift.Error) -> Observable<R> in
            let apiRequest: URLRequest? = response.request
            let apiResponse: URLResponse? = response.response
            
            switch error {
            case MoyaError.statusCode(let response):
                let errorMessage = errorHandler.statusCodeError(response.statusCode, request: apiRequest, response: apiResponse)
                
                throw MoyaResponseError.statusCodeError(message: errorMessage, statusCode: response.statusCode, request: apiRequest, response: apiResponse)
            case MoyaError.imageMapping, MoyaError.jsonMapping, MoyaError.requestMapping, MoyaError.stringMapping:
                let errorMessage = errorHandler.moyaError(error as! MoyaError, request: apiRequest, response: apiResponse)
                
                throw MoyaResponseError.moyaError(message: errorMessage, originalError: error as! MoyaError, request: apiRequest, response: apiResponse)
            case MoyaError.underlying(let error):
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case URLError.Code.notConnectedToInternet:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.notConnectedToInternet(urlError), request: apiRequest, response: apiResponse)
                        
                        throw MoyaResponseError.networkingError(message: errorMessage, originalError: urlError, request: apiRequest, response: apiResponse)
                    case URLError.Code.timedOut, URLError.Code.networkConnectionLost, URLError.Code.dnsLookupFailed:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.badNetworkRequest(urlError), request: apiRequest, response: apiResponse)
                        
                        throw MoyaResponseError.networkingError(message: errorMessage, originalError: urlError, request: apiRequest, response: apiResponse)
                    case URLError.Code.cancelled:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.cancelledRequest(urlError), request: apiRequest, response: apiResponse)
                        
                        throw MoyaResponseError.networkingError(message: errorMessage, originalError: urlError, request: apiRequest, response: apiResponse)
                    default:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.failedNetworkRequest(urlError), request: apiRequest, response: apiResponse)
                        
                        throw MoyaResponseError.networkingError(message: errorMessage, originalError: urlError, request: apiRequest, response: apiResponse)
                    }
                } else {
                    let errorMessage = errorHandler.unknownError(error, request: apiRequest, response: apiResponse)
                    
                    throw MoyaResponseError.otherError(message: errorMessage, originalError: error, request: apiRequest, response: apiResponse)
                }
            default:
                let errorMessage = errorHandler.unknownError(error, request: apiRequest, response: apiResponse)
                
                throw MoyaResponseError.otherError(message: errorMessage, originalError: error, request: apiRequest, response: apiResponse)
            }
        }
    }
    
    private func errorHandlerNotSet() {
        fatalError("You forgot to construct the MoyaResponseErrorHandlerPlugin with an instance of a default errorHandler instance or provide an instance of errorHandler into response function.")
    }
    
    /// Filters out responses that don't fall within the given range, generating errors when others are encountered. Then, process the error Moya has thrown and create a human readable error string for it.
    public func filterStatusCodesProcessErrors(statusCodes: ClosedRange<Int>, errorHandler: MoyaResponseErrorHandlerProtocol? = nil) -> Observable<E> {
        guard let errorHandler = errorHandler ?? Configuration.sharedInstance.errorHandler else {
            errorHandlerNotSet()
            return Observable.error(MoyaResponseHandlerFatalError.errorHandlerNotSet)
        }
        
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filter(statusCodes: statusCodes))
                .catchError(self.errorProcessor(response: response, errorHandler: errorHandler))
        }
    }
    
    public func filterStatusCodesProcessErrors(statusCodes: [ClosedRange<Int>], errorHandler: MoyaResponseErrorHandlerProtocol? = nil) -> Observable<E> {
        guard let errorHandler = errorHandler ?? Configuration.sharedInstance.errorHandler else {
            errorHandlerNotSet()
            return Observable.error(MoyaResponseHandlerFatalError.errorHandlerNotSet)
        }
        
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filter(statusCodes: statusCodes))
                .catchError(self.errorProcessor(response: response, errorHandler: errorHandler))
        }
    }
    
    public func filterStatusCodesProcessErrors(statusCode: Int, errorHandler: MoyaResponseErrorHandlerProtocol? = nil) -> Observable<E> {
        guard let errorHandler = errorHandler ?? Configuration.sharedInstance.errorHandler else {
            errorHandlerNotSet()
            return Observable.error(MoyaResponseHandlerFatalError.errorHandlerNotSet)
        }
        
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filter(statusCode: statusCode))
                .catchError(self.errorProcessor(response: response, errorHandler: errorHandler))
        }
    }
    
    public func filterSuccessfulStatusCodesProcessErrors(append statusCodes: [ClosedRange<Int>] = [], errorHandler: MoyaResponseErrorHandlerProtocol? = nil) -> Observable<E> {
        guard let errorHandler = errorHandler ?? Configuration.sharedInstance.errorHandler else {
            errorHandlerNotSet()
            return Observable.error(MoyaResponseHandlerFatalError.errorHandlerNotSet)
        }
        
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filterSuccessfulStatusCodesAppend(statusCodes: statusCodes))
                .catchError(self.errorProcessor(response: response, errorHandler: errorHandler))
        }
    }
    
    public func filterSuccessfulStatusAndRedirectCodesProcessErrors(append statusCodes: [ClosedRange<Int>] = [], errorHandler: MoyaResponseErrorHandlerProtocol? = nil) -> Observable<E> {
        guard let errorHandler = errorHandler ?? Configuration.sharedInstance.errorHandler else {
            errorHandlerNotSet()
            return Observable.error(MoyaResponseHandlerFatalError.errorHandlerNotSet)
        }
        
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filterSuccessfulStatusAndRedirectCodesAppend(statusCodes: statusCodes))
                .catchError(self.errorProcessor(response: response, errorHandler: errorHandler))
        }
    }
    
    /// Maps data received from the signal into an Image. If the conversion fails, the signal errors. Then, process the error Moya has thrown and create a human readable error string for it.
    public func mapImageProcessErrors(errorHandler: MoyaResponseErrorHandlerProtocol? = nil) -> Observable<Image?> {
        guard let errorHandler = errorHandler ?? Configuration.sharedInstance.errorHandler else {
            errorHandlerNotSet()
            return Observable.error(MoyaResponseHandlerFatalError.errorHandlerNotSet)
        }
        
        return flatMap { response -> Observable<Image?> in
            return Observable.just(try response.mapImage())
                .catchError(self.errorProcessor(response: response, errorHandler: errorHandler))
        }
    }
    
    /// Maps data received from the signal into a JSON object. If the conversion fails, the signal errors. Then, process the error Moya has thrown and create a human readable error string for it.
    public func mapJSONProcessErrors(failsOnEmptyData: Bool = true, errorHandler: MoyaResponseErrorHandlerProtocol? = nil) -> Observable<Any> {
        guard let errorHandler = errorHandler ?? Configuration.sharedInstance.errorHandler else {
            errorHandlerNotSet()
            return Observable.error(MoyaResponseHandlerFatalError.errorHandlerNotSet)
        }
        
        return flatMap { response -> Observable<Any> in
            return Observable.just(try response.mapJSON(failsOnEmptyData: failsOnEmptyData))
                .catchError(self.errorProcessor(response: response, errorHandler: errorHandler))
        }
    }
    
    /// Maps received data at key path into a String. If the conversion fails, the signal errors. Then, process the error Moya has thrown and create a human readable error string for it.
    public func mapStringProcessErrors(atKeyPath keyPath: String? = nil, errorHandler: MoyaResponseErrorHandlerProtocol? = nil) -> Observable<String> {
        guard let errorHandler = errorHandler ?? Configuration.sharedInstance.errorHandler else {
            errorHandlerNotSet()
            return Observable.error(MoyaResponseHandlerFatalError.errorHandlerNotSet)
        }
        
        return flatMap { response -> Observable<String> in
            return Observable.just(try response.mapString(atKeyPath: keyPath))
                .catchError(self.errorProcessor(response: response, errorHandler: errorHandler))
        }
    }
}

public extension Response {
    
    /**
     Returns the `Response` if the `statusCode` falls within the specified range.
     
     - parameters:
     - statusCodes: The range of acceptable status codes.
     - throws: `MoyaError.statusCode` when others are encountered.
     */
    public func filter(statusCodes: [ClosedRange<Int>]) throws -> Response {
        var successfulStatusCode = false
        statusCodes.forEach { (statsCodesSet: ClosedRange<Int>) in
            if statsCodesSet.contains(statusCode) {
                successfulStatusCode = true
            }
        }
        
        if successfulStatusCode {
            return self
        }
        throw MoyaError.statusCode(self)
    }
    
    public func filterSuccessfulStatusCodesAppend(statusCodes: [ClosedRange<Int>]) throws -> Response {
        var allStatusCodes = statusCodes
        allStatusCodes.append(200...299)
        
        var successfulStatusCode = false
        allStatusCodes.forEach { (statsCodesSet: ClosedRange<Int>) in
            if statsCodesSet.contains(statusCode) {
                successfulStatusCode = true
            }
        }
        
        if successfulStatusCode {
            return self
        }
        throw MoyaError.statusCode(self)
    }
    
    public func filterSuccessfulStatusAndRedirectCodesAppend(statusCodes: [ClosedRange<Int>]) throws -> Response {
        var allStatusCodes = statusCodes
        allStatusCodes.append(200...399)
        
        var successfulStatusCode = false
        allStatusCodes.forEach { (statsCodesSet: ClosedRange<Int>) in
            if statsCodesSet.contains(statusCode) {
                successfulStatusCode = true
            }
        }
        
        if successfulStatusCode {
            return self
        }
        throw MoyaError.statusCode(self)
    }
    
}
