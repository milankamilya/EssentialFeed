//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by MK on 03/02/22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL: URL, completion: @escaping (Result) -> Void)
}
