//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by MK on 14/12/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizationStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeysAndValuesExist(in: presentationBundle, table)
    }
}
