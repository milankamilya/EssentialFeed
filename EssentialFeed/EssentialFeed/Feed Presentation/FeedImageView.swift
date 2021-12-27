//
//  FeedImageView.swift
//  EssentialFeed
//
//  Created by MK on 27/12/21.
//

import Foundation

public struct FeedImageViewModel<Image> {
    let image: Image?
    let description: String?
    let location: String?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

extension FeedImageViewModel : Equatable where Image : Equatable {
    
}
