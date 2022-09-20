//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by MK on 25/04/22.
//

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJSON(items: [])

        let samples = [199, 150, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data( "invalid json".utf8)
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoitemsON2xxHTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON(items: [])
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyListJSON, HTTPURLResponse(statusCode: code))
            
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversFeeditemsON2xxHTTPResponseJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (date: Date(timeIntervalSince1970: 1598627222), iso8601String: "2020-08-28T15:07:02+00:00"),
            username: "a username")
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (date: Date(timeIntervalSince1970: 1598627222), iso8601String: "2020-08-28T15:07:02+00:00"),
            username: "another username")
 
        let items = [item1.model, item2.model]
        let json = makeItemsJSON(items: [item1.json, item2.json])

        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            
            XCTAssertEqual(result, items)
        }
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        
        return (item, json)
    }
}
