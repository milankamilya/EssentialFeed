//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by MK on 03/02/22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrieveResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func retrieve(dataForURL: URL, completion: @escaping (RetrieveResult) -> Void)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}
