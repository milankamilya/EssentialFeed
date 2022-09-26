//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by MK on 20/09/22.
//

import XCTest
@testable import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    func test_localizationStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let presentationBundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        
        assertLocalizedKeysAndValuesExist(in: presentationBundle, table)
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
