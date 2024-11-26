//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 23/11/24.
//

import EssentialFeed
import XCTest

final class ImageCommentsMapperTests: XCTestCase {
    func test_map_deliverErrorOnNon2XXHTTPResponse() throws {
        let samples = [199, 150, 300, 400, 500]
        let json = makeItemJson([])

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_deliverErrorOn2XXHTTPResponseWithInvalidJSON() throws {
        let samples = [200, 250, 280, 299]
        let invalidJSON = Data("invalid Json".utf8)

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, response: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_deliverNoItemListon2XXHTTPResponseWithEmptyJSONList() throws {
        let samples = [200, 250, 280, 299]
        let emptyListJson = makeItemJson([])

        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyListJson, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }

    func test_map_deliverItemListon2XXHTTPResponseWithJSONList() throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username")

        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username")

        let items = [item1.model, item2.model]
        let jsonData = makeItemJson([item1.json, item2.json])
        let samples = [200, 250, 280, 299]

        try samples.forEach { code in

            let result = try ImageCommentsMapper.map(jsonData, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, items)
        }
    }

    // Helpers

    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }

    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)

        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username,
            ],
        ]

        return (item, json)
    }

    private func makeItemJson(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]

        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
}
