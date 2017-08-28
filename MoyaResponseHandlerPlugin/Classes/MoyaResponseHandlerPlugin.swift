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

internal class Configuration {
    
    internal var errorHandler: MoyaResponseErrorHandlerProtocol?
    
    static let sharedInstance = Configuration()
    
    private init() {
    }
}

/**
 Moya plugin that logs the Moya API network response before completion handler is called. 
 
 To use, provide the plugin to your MoyaProvider constructor: `MoyaProvider<Target>(plugins: [MoyaResponseHandlerPlugin(logger: MyMoyaResponseLogger())])`
 */
public class MoyaResponseHandlerPlugin: PluginType {
    
    /// Provide the MoyaResponseHandlerPlugin with your logger instance if you wish.
    public init(errorHandler: MoyaResponseErrorHandlerProtocol) {
        Configuration.sharedInstance.errorHandler = errorHandler
    }
    
}
