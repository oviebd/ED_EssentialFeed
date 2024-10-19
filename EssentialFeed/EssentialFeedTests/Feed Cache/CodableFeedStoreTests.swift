//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 19/10/24.
//

import XCTest
import EssentialFeed

class CodableFeedStore{
    func retrive(completion: @escaping FeedStore.RetrievalCompletion ){
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {

    func test_rerieve_deliversEmptyOnEmotyCache(){
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache cache retrieval")
        sut.retrive { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expects empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_rerieve_hasNoSideEffectsOnEmotyCache(){
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache cache retrieval")
        sut.retrive { firstResult in
            sut.retrive { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
            
           
        }
        wait(for: [exp], timeout: 1)
    }
    

}
