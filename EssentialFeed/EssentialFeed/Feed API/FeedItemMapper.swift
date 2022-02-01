//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by MK on 06/11/21.
//

import Foundation

 final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
                
        return root.items
    }
    
}


