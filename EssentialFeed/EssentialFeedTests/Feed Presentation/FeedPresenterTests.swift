//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by MK on 20/12/21.
//

import Foundation
import XCTest

private final class FeedPresenter {
    init(view: Any) {
        
    }
}

final class FeedPresenterTests : XCTestCase {
    func test_init_doesNotSendAnyMessagesToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected not to receive any messages, but received \(view.messages) instead.")
    }
    
    // MARK: - Helpers
    private class ViewSpy {
        let messages = [Any]()
    }
}
