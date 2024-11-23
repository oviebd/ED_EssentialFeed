//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 23/11/24.
//

import EssentialFeed
import XCTest

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesnotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url: URL = URL(string: "https://https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual([url], client.requestedUrls)
    }

    func test_loadTwicw_requestsDataFromURLTwicw() {
        let url: URL = URL(string: "https://https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedUrls, [url, url])
    }

    func test_load_deliverErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliverErrorOnNon2XXHTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 150, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemJson([])
                client.complete(with: code, data: json, at: index)

            })
        }
    }

    func test_load_deliverErrorOn2XXHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        let samples = [200, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("invalid Json".utf8)
                client.complete(with: code, data: invalidJSON, at: index)
            })
        }
    }

    func test_load_deliverNoItemListon2XXHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        let samples = [200, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([])) {
                let emptyListJson = makeItemJson([])
                client.complete(with: code, data: emptyListJson, at: index)
            }
        }
    }

    func test_load_deliverItemListon2XXHTTPResponseWithJSONList() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http:/a-url.com")!)

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a Location",
            imageURL: URL(string: "http:/another-url.com")!)

        let items = [item1.model, item2.model]
        let samples = [200, 250, 280, 299]

        samples.enumerated().forEach { index, code in

            expect(sut, toCompleteWith: .success(items)) {
                let jsonData = makeItemJson([item1.json, item2.json])
                client.complete(with: code, data: jsonData, at: index)
            }
        }
    }

    func test_load_doesnotDeliverResultAfterSUTInstanceHasBeenDeAllocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client, url: url)

        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(with: 200, data: Data())
        XCTAssertTrue(capturedResults.isEmpty)
    }

    // Helpers

    private func makeSUT(url: URL = URL(string: "https://https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(client: client, url: url)

        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, client)
    }

    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }

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

    private func makeItemJson(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]

        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }

    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):

                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result: \(receivedResult) got \(receivedResult)", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
}
