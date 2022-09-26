//
//  FeedImageView.swift
//  EssentialFeed
//
//  Created by MK on 27/12/21.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
