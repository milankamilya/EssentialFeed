//
//  FeedImageView.swift
//  EssentialFeed
//
//  Created by MK on 27/12/21.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let image: Image?
    public let description: String?
    public let location: String?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}

extension FeedImageViewModel : Equatable where Image : Equatable {
    
}
