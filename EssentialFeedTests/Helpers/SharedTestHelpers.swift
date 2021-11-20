//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by MK on 15/11/21.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}
