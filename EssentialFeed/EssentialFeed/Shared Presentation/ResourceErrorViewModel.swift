//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by MK on 20/12/21.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel { ResourceErrorViewModel(message: nil) }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
