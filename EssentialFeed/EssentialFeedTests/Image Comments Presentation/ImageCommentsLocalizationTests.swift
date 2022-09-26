//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by MK on 26/09/22.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizationStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeysAndValuesExist(in: presentationBundle, table)
    }
}
