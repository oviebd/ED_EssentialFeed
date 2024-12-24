//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/10/24.
//

import EssentialFeed
import XCTest

class FeedItemMapperTest: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        let json = makeItemJson([])

        try samples.forEach { code in

            XCTAssertThrowsError(
                try FeedItemMapper.map(json, response: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid Json".utf8)

        XCTAssertThrowsError(
            try FeedItemMapper.map(invalidJSON,response: HTTPURLResponse(statusCode: 200))
        )
    }

    func test_map_deliverNoItemListon200HTTPResponseWithEmptyJSONList() throws {
        
        let emptyListJson = makeItemJson([])
        
        let result = try FeedItemMapper.map(emptyListJson,response: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }

    func test_map_deliverItemListon200HTTPResponseWithJSONList() throws{

        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http:/a-url.com")!)

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a Location",
            imageURL: URL(string: "http:/another-url.com")!)

        let items = [item1.model, item2.model]
        let jsonData = makeItemJson([item1.json, item2.json])
        let result = try FeedItemMapper.map(jsonData,response: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, items)
    }

    // Helpers

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString,
        ].compactMapValues { $0 }

        return (item, json)
    }

  
}
