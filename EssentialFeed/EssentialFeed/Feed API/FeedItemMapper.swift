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
    
     static var OK_200: Int { return 200 }

     static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
                
        return root.items
    }
    
}


