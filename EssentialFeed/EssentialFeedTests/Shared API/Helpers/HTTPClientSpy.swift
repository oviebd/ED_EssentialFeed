//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 11/11/24.
//

//import Foundation
//import EssentialFeed
//
// public class HTTPClientSpy: HTTPClient {
//    private struct Task: HTTPClientTask {
//        func cancel() {}
//    }
//
//    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
//
//    var requestedUrls: [URL] {
//        return messages.map { $0.url }
//    }
//
//     public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
//        messages.append((url, completion))
//        return Task()
//    }
//
//    func complete(with error: Error, at index: Int = 0) {
//        messages[index].completion(.failure(error))
//    }
//
//    func complete(with statusCode: Int, data: Data, at index: Int = 0) {
//        let response = HTTPURLResponse(
//            url: requestedUrls[index],
//            statusCode: statusCode,
//            httpVersion: nil,
//            headerFields: nil)!
//
//        messages[index].completion(.success((data, response)))
//    }
//}
