//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by MK on 17/12/21.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel { FeedErrorViewModel(message: nil) }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
