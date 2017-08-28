//
//  Single+Extensions.swift
//  Pods
//
//  Created by Levi Bostian on 8/28/17.
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
            return NSLocalizedString("You did not set an error handler for Lucid.", comment: "")
        }
    }
}

public extension PrimitiveSequence where TraitType == SingleTrait {
    
    private func errorProcessor<R>(errorHandler: LucidMoyaResponseErrorProtocol?) -> (Swift.Error) throws -> Single<R> {
        return { (error: Swift.Error) -> Single<R> in
            throw error.getLucidError()
        }
    }
    
    /// Use in replace of existing `.subscribe()` function to process any of the thrown errors in the Observable chain and return a human readable error for thrown error.
    public func subscribeProcessErrors(errorHandler: LucidMoyaResponseErrorProtocol? = Singleton.sharedInstance.errorHandler, onSuccess: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil) -> Disposable {
        return catchError(self.errorProcessor(errorHandler: errorHandler))
            .subscribe(onSuccess: onSuccess, onError: onError)
    }
    
}
