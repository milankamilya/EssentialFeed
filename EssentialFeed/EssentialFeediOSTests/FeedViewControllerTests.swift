//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by MK on 22/11/21.
//

import XCTest

private class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        
        _ = FeedViewController(loader: loader)
                
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    class LoaderSpy {
        var loadCallCount = 0
    }
    
}

