//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by MK on 14/09/22.
//

import Foundation

public final class RemoteLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result)-> Void) {
        client.get(from: url) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteLoader.map(data, response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
        
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}



