//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by MK on 15/11/21.
//

import Foundation

final class FeedCachePolicy {
    static let calender = Calendar(identifier: .gregorian)

    private init() { }
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return date < maxCacheAge
    }
}
