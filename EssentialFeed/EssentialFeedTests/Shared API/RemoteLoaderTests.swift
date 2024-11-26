//
//  RemoteLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 25/11/24.
//

//import XCTest
//import EssentialFeed
//
//final class RemoteLoaderTests: XCTestCase {
//
//    func test_init_doesnotRequestDataFromURL() {
//        let (_, client) = makeSUT()
//        XCTAssertTrue(client.requestedUrls.isEmpty)
//    }
//
//    func test_load_requestsDataFromURL() {
//        let url: URL = URL(string: "https://https://a-url.com")!
//        let (sut, client) = makeSUT(url: url)
//        sut.load { _ in }
//        XCTAssertEqual([url], client.requestedUrls)
//    }
//
//    func test_loadTwicw_requestsDataFromURLTwicw() {
//        let url: URL = URL(string: "https://https://a-url.com")!
//        let (sut, client) = makeSUT(url: url)
//        sut.load { _ in }
//        sut.load { _ in }
//        XCTAssertEqual(client.requestedUrls, [url, url])
//    }
//
//    func test_load_deliverErrorOnClientError() {
//        let (sut, client) = makeSUT()
//
//        expect(sut, toCompleteWith: failure(.connectivity), when: {
//            let clientError = NSError(domain: "Test", code: 0)
//            client.complete(with: clientError)
//        })
//    }
//
//    
//    func test_load_deliverErrorOnMapperError() {
//        let (sut, client) = makeSUT(mapper : { _ , _ in
//            throw anyNSError()
//        })
//        expect(sut, toCompleteWith: failure(.invalidData), when: {
//            client.complete(with: 200, data: anyData())
//        })
//    }
//
//    
//
//    func test_load_deliversMappedResource() {
//        let resource = "a resource"
//        let (sut, client) = makeSUT(mapper: { data, _ in
//            String(data: data, encoding: .utf8)!
//        })
//
//        expect(sut, toCompleteWith: .success(resource)) {
//            client.complete(with: 200, data: Data(resource.utf8))
//        }
//    }
//
//    func test_load_doesnotDeliverResultAfterSUTInstanceHasBeenDeAllocated() {
//        let url = URL(string: "http://any-url.com")!
//        let client = HTTPClientSpy()
//        var sut: RemoteLoader<String>? = RemoteLoader<String>( client: client, url: url, mapper: { _, _ in "any"})
//
//        var capturedResults = [RemoteLoader<String>.Result]()
//        sut?.load { capturedResults.append($0) }
//
//        sut = nil
//        client.complete(with: 200, data: Data())
//        XCTAssertTrue(capturedResults.isEmpty)
//    }
//
//    // Helpers
//
//      
//    private func makeSUT(
//        url: URL = URL(string: "https://https://a-url.com")!,
//        mapper : @escaping RemoteLoader<String>.Mapper = {_, _ in "any"},
//        file: StaticString = #file,
//        line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
//        let client = HTTPClientSpy()
//            let sut = RemoteLoader<String>(client: client, url: url, mapper: mapper)
//
//        trackForMemoryLeaks(client, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)
//
//        return (sut, client)
//    }
//
//    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
//        return .failure(error)
//    }
//
//    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
//        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
//        let json = [
//            "id": id.uuidString,
//            "description": description,
//            "location": location,
//            "image": imageURL.absoluteString,
//        ].compactMapValues { $0 }
//
//        return (item, json)
//    }
//
//    private func makeItemJson(_ items: [[String: Any]]) -> Data {
//        let itemsJSON = ["items": items]
//
//        return try! JSONSerialization.data(withJSONObject: itemsJSON)
//    }
//
//    private func expect(_ sut: RemoteLoader<String>, toCompleteWith expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
//        let exp = expectation(description: "Wait for load completion")
//
//        sut.load { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case let (.success(receivedItems), .success(expectedItems)):
//                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
//
//            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
//
//                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
//
//            default:
//                XCTFail("Expected result: \(receivedResult) got \(receivedResult)", file: file, line: line)
//            }
//
//            exp.fulfill()
//        }
//
//        action()
//
//        wait(for: [exp], timeout: 1.0)
//    }
//
//
//}
