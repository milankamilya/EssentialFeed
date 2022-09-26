//
//  FeedImagePresenter.swift
//  EssentialFeedTests
//
//  Created by MK on 21/12/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
}

