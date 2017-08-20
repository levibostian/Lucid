//
//  MoyaResponseError.swift
//  Pods
//
//  Created by Levi Bostian on 8/20/17.
//
//

import Foundation

public enum MoyaResponseError: Swift.Error, LocalizedError {
    case networkingError(message: String)
    case statusCodeError(message: String)
    case moyaError(message: String)
    case otherError(message: String) // not any of the URLError options. Some other Swift.Error option.
    
    public var errorDescription: String? {
        switch self {
        case .networkingError(let message):
            return NSLocalizedString(message, comment: "No Internet, timeout, etc. Any of the URLError options.")
        case .statusCodeError(let message):
            return NSLocalizedString(message, comment: "Status code >= 300.")
        case .moyaError(let message):
            return NSLocalizedString(message, comment: "Moya specific error. Error creating Moya Endpoint, parsing JSON/Image/String, invalid status code received.")
        case .otherError(let message):
            return NSLocalizedString(message, comment: "Not any of the URLError options. Some other Swift.Error option.")
        }
    }
}
