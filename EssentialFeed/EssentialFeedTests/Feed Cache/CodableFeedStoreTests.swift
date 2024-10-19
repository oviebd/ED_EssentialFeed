//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 19/10/24.
//

import XCTest
import EssentialFeed



class CodableFeedStore{
    
    private struct Cache : Codable {
        let feed : [LocalFeedImage]
        let timeStamp : Date
    }
    
    let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrive(completion: @escaping FeedStore.RetrievalCompletion ){
        
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(cache.feed, timestamp: cache.timeStamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion){
        
        let encoder = JSONEncoder()
        let encoded = try!  encoder.encode(Cache(feed: feed, timeStamp: timeStamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
  
}

final class CodableFeedStoreTests: XCTestCase {

    override class func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    
    override func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
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
    
    func test_rerieveAfterInsertingToEmptyCache_deliversInsertedValues(){
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache cache retrieval")
        sut.insert(feed, timeStamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrive { retrieveResult in
              
                switch retrieveResult {
                case let .found(retrievedFeed, retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed,feed)
                    XCTAssertEqual(retrievedTimestamp,timestamp)
                    break
                default:
                    XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                exp.fulfill()
            }
            
           
        }
        wait(for: [exp], timeout: 1)
    }
    

}
