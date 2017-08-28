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

public extension ObservableType where E == Response {
    
    /// Filters out responses that don't fall within the given range, generating errors when others are encountered.
    public func filter(statusCodes: [ClosedRange<Int>]) -> Observable<E> {
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filter(statusCodes: statusCodes))
        }
    }
    
    /// Filters out responses that do not have a status code >=200, <300 and don't fall within the given range, generating errors when others are encountered.
    public func filterSuccessfulStatusCodesAppend(code: Int? = nil, statusCodes: [ClosedRange<Int>] = []) -> Observable<E> {
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filterSuccessfulStatusCodesAppend(code: code, statusCodes: statusCodes))
        }
    }
    
    /// Filters out responses that do not have a status code >=200, <400 and don't fall within the given range, generating errors when others are encountered.
    public func filterSuccessfulStatusAndRedirectCodesAppend(code: Int? = nil, statusCodes: [ClosedRange<Int>] = []) -> Observable<E> {
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filterSuccessfulStatusAndRedirectCodesAppend(code: code, statusCodes: statusCodes))
        }
    }
    
}


