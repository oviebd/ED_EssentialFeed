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
        let feed : [CodableFeedImage]
        let timeStamp : Date
        
        var localfeed : [LocalFeedImage] {
            return feed.map{$0.local}
        }
    }
    
    private struct CodableFeedImage : Codable{
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        
        init(_ image : LocalFeedImage){
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local : LocalFeedImage{
            return LocalFeedImage(id: id, description: description, location: location, imageURL: url)
        }
    }
    
    let storeURL : URL
    init(storeURL: URL){
        self.storeURL = storeURL
    }
    
    func retrive(completion: @escaping FeedStore.RetrievalCompletion ){
        
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(cache.localfeed, timestamp: cache.timeStamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion){
        
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timeStamp: timeStamp)
        let encoded = try!  encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
  
}

final class CodableFeedStoreTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        setupEmptyStoreState ()
    }
    
    override func setUp() {
        super.setUp()
        undoStoreSideEffects()
    }
    
    
    func test_rerieve_deliversEmptyOnEmotyCache(){
        let sut = makeSUT()
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_rerieve_hasNoSideEffectsOnEmotyCache(){
        let sut = makeSUT()
        
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
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache cache retrieval")
        sut.insert(feed, timeStamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        
        expect(sut, toRetrive: .found(feed, timestamp: timestamp))
    }
    
    
    func test_rerieve_hasNoSideffectsOnNonEmptyCache(){
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache cache retrieval")
        sut.insert(feed, timeStamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrive { firstResult in
                sut.retrive { secondResult in
                    switch (firstResult, secondResult) {
                   
                    case let (.found(firstFeed,firstTimestamp), .found(secondFeed,secondTimestamp)):
                        XCTAssertEqual(firstFeed,feed)
                        XCTAssertEqual(firstTimestamp,timestamp)
                        
                        XCTAssertEqual(secondFeed,feed)
                        XCTAssertEqual(secondTimestamp,timestamp)
                        
                        break
                    
                    default:
                        XCTFail("Expected retrieving twice from non empty cache to deliver same found result with feed \(feed) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead")
                    }
                    exp.fulfill()
                }
            }
           
        }
        wait(for: [exp], timeout: 1)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file:StaticString = #file, line:  UInt = #line) -> CodableFeedStore {
     
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrive expectedResult: RetriveCacheFeedResult, file:StaticString = #file, line:  UInt = #line){
        
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrive { retrievedResult in
           
            switch (expectedResult,retrievedResult) {
            case (.empty,.empty):
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp,retrievedTimestamp, file: file, line: line)
                
                break
                
            default:
                XCTFail("Expects to retrieve \(expectedResult) got \(retrievedResult)instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
    }
    
    
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    private func undoStoreSideEffects(){
        deleteStoreArtifacts()
    }
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    

    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(String(describing: type(of: self).description))s.store")
    }
}


