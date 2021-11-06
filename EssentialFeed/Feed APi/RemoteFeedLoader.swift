//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by MK on 02/11/21.
//

import Foundation

public typealias CommonCompletionType = (Error?, HTTPURLResponse?) -> Void

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = LoadFeedResult<Error>
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result)-> Void) {
        client.get(from: url) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, response))

            case .error:
                completion(.failure(.connectivity))
            }
        }
        
    }
}
