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
    
    internal var errorHandler: LucidMoyaResponseErrorProtocol?
    
    static let sharedInstance = Singleton()
    
    private init() {
    }
}

/**
 Configure Lucid. Set defaults for the plugin.
 */
public class LucidConfiguration {
    
    public class func setDefaultErrorHandler(_ errorHandler: LucidMoyaResponseErrorProtocol?) {
        Singleton.sharedInstance.errorHandler = errorHandler
    }
    
}


