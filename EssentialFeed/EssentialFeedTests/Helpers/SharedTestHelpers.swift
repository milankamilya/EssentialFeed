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

func anyData() -> Data {
    return Data("any data".utf8)
}

func makeItemsJSON(items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func adding(minutes: Int, calerdar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calerdar.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int, calerdar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calerdar.date(byAdding: .day, value: days, to: self)!
    }
}
