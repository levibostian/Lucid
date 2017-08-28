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

internal class Singleton {
    
    internal var errorHandler: MoyaResponseErrorHandlerProtocol?
    
    static let sharedInstance = Singleton()
    
    private init() {
    }
}

/**
 Configure the MoyaResponseHandlerPlugin. Set defaults for the plugin.  
 */
public class MoyaResponseHandlerPluginConfiguration {
    
    public class func setDefaultErrorHandler(_ errorHandler: MoyaResponseErrorHandlerProtocol?) {
        Singleton.sharedInstance.errorHandler = errorHandler
    }
    
}


