//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by MK on 20/12/21.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel { FeedErrorViewModel(message: nil) }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
