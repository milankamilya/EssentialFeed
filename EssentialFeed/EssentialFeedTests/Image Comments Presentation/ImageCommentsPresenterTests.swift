//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by MK on 26/09/22.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
    func test_title_localized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    // MARK: - Helpers
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table: String = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value  = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized value for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
