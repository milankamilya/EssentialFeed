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
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected not to receive any messages, but received \(view.messages) instead.")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
