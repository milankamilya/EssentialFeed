//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by MK on 06/11/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
