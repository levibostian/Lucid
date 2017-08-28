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

public extension PrimitiveSequence where TraitType == SingleTrait {
    
    private func errorProcessor<R>(errorHandler: MoyaResponseErrorHandlerProtocol) -> (Swift.Error) throws -> Single<R> {
        return { (error: Swift.Error) -> Single<R> in
            switch error {
            case MoyaError.statusCode(let response):
                let errorMessage = errorHandler.statusCodeError(response.statusCode, request: response.request, response: response.response)
                
                throw MoyaResponseError.statusCodeError(message: errorMessage, statusCode: response.statusCode, request: response.request, response: response.response)
            case MoyaError.imageMapping, MoyaError.jsonMapping, MoyaError.requestMapping, MoyaError.stringMapping:
                let errorMessage = errorHandler.moyaError(error as! MoyaError)
                
                throw MoyaResponseError.moyaError(message: errorMessage, originalError: error as! MoyaError)
            case MoyaError.underlying(let error):
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case URLError.Code.notConnectedToInternet:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.notConnectedToInternet(urlError))
                        
                        throw MoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    case URLError.Code.timedOut, URLError.Code.networkConnectionLost, URLError.Code.dnsLookupFailed:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.badNetworkRequest(urlError))
                        
                        throw MoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    case URLError.Code.cancelled:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.cancelledRequest(urlError))
                        
                        throw MoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    default:
                        let errorMessage = errorHandler.networkingError(MoyaNetworkingError.failedNetworkRequest(urlError))
                        
                        throw MoyaResponseError.networkingError(message: errorMessage, originalError: urlError)
                    }
                } else {
                    let errorMessage = errorHandler.unknownError(error)
                    
                    throw MoyaResponseError.otherError(message: errorMessage, originalError: error)
                }
            default:
                let errorMessage = errorHandler.unknownError(error)
                
                throw MoyaResponseError.otherError(message: errorMessage, originalError: error)
            }
        }
    }
    
    private func errorHandlerNotSet() {
        fatalError("You forgot to construct the MoyaResponseErrorHandlerPlugin with an instance of a default errorHandler instance or provide an instance of errorHandler into response function.")
    }
    
    public func subscribeProcessErrors(onSuccess: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, errorHandler: MoyaResponseErrorHandlerProtocol? = Singleton.sharedInstance.errorHandler) -> Disposable {
        guard let errorHandler = errorHandler else {
            errorHandlerNotSet()
            return Disposables.create()
        }
        
        return catchError(self.errorProcessor(errorHandler: errorHandler))
            .subscribe(onSuccess: onSuccess, onError: onError)
    }
    
}

public extension ObservableType where E == Response {
    
    /// Filters out responses that don't fall within the given range, generating errors when others are encountered.
    public func filter(statusCodes: [ClosedRange<Int>]) -> Observable<E> {
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filter(statusCodes: statusCodes))
        }
    }
    
    public func filterSuccessfulStatusCodesAppend(code: Int? = nil, statusCodes: [ClosedRange<Int>] = []) -> Observable<E> {
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filterSuccessfulStatusCodesAppend(code: code, statusCodes: statusCodes))
        }
    }
    
    public func filterSuccessfulStatusAndRedirectCodesAppend(code: Int? = nil, statusCodes: [ClosedRange<Int>] = []) -> Observable<E> {
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filterSuccessfulStatusAndRedirectCodesAppend(code: code, statusCodes: statusCodes))
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
    
    public func filterSuccessfulStatusCodesAppend(code: Int? = nil, statusCodes: [ClosedRange<Int>] = []) throws -> Response {
        var allStatusCodes = statusCodes
        
        if let code = code { allStatusCodes.append(code...code) }
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
    
    public func filterSuccessfulStatusAndRedirectCodesAppend(code: Int? = nil, statusCodes: [ClosedRange<Int>] = []) throws -> Response {
        var allStatusCodes = statusCodes
        
        if let code = code { allStatusCodes.append(code...code) }
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
