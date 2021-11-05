//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by MK on 01/11/21.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
}

