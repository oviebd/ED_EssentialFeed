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

func makeItemJson(_ items: [[String: Any]]) -> Data {
    let itemsJSON = ["items": items]

    return try! JSONSerialization.data(withJSONObject: itemsJSON)
}
extension HTTPURLResponse{
    
    convenience init(statusCode: Int){
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }

    func adding(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

