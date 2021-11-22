//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by MK on 13/11/21.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
