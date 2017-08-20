//
//  MoyaNetworkingError.swift
//  Pods
//
//  Created by Levi Bostian on 8/20/17.
//
//

import Foundation

public enum MoyaNetworkingError {
    case notConnectedToInternet(URLError) // not connected to Internet error returned.
    case badNetworkRequest(URLError) // timeout, connection lost, DNS issues. You can probably retry this again.
    case cancelledRequest(URLError) // cancelled request.
    case failedNetworkRequest(URLError) // SSL server issues, too many redirects, etc. All other error types. Probably an error that is a developer issue in app or API that needs to be fixed. User cannot do anything about it.
}
