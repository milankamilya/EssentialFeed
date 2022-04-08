//
//  FeedViewControllerTests+Assertions.swift
//  EssentialFeediOSTests
//
//  Created by MK on 14/12/21.
//

import Foundation
import XCTest
@testable import EssentialFeediOS
@testable import EssentialFeed

extension FeedUIIntegrationTests {
    
    func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        sut.view.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        
        guard sut.numberOfRenderedFeedImageView() == feed.count else {
            XCTFail("Expected \(feed.count) cells to render, but render only \(sut.numberOfRenderedFeedImageView()) instead.", file: file, line: line)
            return
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            return
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible), got \(cell.isShowingLocation) instead", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)), got \(String(describing: cell.locationText)) instead.", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description test to be \(String(describing: image.description)), got \(String(describing: cell.locationText)) instead.", file: file, line: line)
    }
}
