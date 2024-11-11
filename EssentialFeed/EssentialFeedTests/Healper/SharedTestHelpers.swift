//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 18/10/24.
//

import Foundation

public func anyURL() -> URL {
    return URL(string: "http://any_url.com")!
}
public func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

public func anyData() -> Data {
    return Data("any data".utf8)
}
