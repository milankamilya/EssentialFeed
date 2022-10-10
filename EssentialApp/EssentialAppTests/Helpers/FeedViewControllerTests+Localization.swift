//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by MK on 14/12/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) { }
    }

    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
}
