//
//  FeedImagePresenter.swift
//  EssentialFeedTests
//
//  Created by MK on 21/12/21.
//

import Foundation
import XCTest

private final class FeedImagePresenter {
    init() {
        
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendAnyMessage() {
        let view = ViewSpy()
        _ = FeedImagePresenter()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected init doesn't send any message, but sent \(view.messages) instead")
    }
    
    // MARK: - Helpers
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
