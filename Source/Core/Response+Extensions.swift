//
//  Response+Extensions.swift
//  Pods
//
//  Created by Levi Bostian on 8/28/17.
//
//

import Foundation
import Moya

public extension Response {
    
    /// Filters out responses that don't fall within the given range, generating errors when others are encountered.
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
    
    /// Filters out responses that do not have a status code >=200, <300 and don't fall within the given range, generating errors when others are encountered.
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
    
    /// Filters out responses that do not have a status code >=200, <400 and don't fall within the given range, generating errors when others are encountered.
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
