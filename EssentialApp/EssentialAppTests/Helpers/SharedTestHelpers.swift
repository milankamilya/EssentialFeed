//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by MK on 02/03/22.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
