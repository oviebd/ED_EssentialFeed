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
        
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(cache.localfeed, timestamp: cache.timeStamp))
        }catch{
            completion(.failure(error))
        }
            
        
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
    
    
    func test_rerieve_deliversEmptyOnEmptyCache(){
        let sut = makeSUT()
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_rerieve_hasNoSideEffectsOnEmotyCache(){
        expect(makeSUT(), toRetriveTwice: .empty)
    }
    
    func test_rerieve_deliversFoundValuesOnNonEmptyCache(){
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetrive: .found(feed, timestamp: timestamp))
    }
    
    
    func test_rerieve_hasNoSideffectsOnNonEmptyCache(){
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetriveTwice: .found(feed, timestamp: timestamp))
    }
    
    func test_rerieve_deliversFailureOnRetrievalError(){
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL : storeURL)
      
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrive: .failure(anyNSError()))
    }
    
    
    
    // - MARK: Helpers
    
    private func makeSUT(storeURL : URL? = nil, file:StaticString = #file, line:  UInt = #line) -> CodableFeedStore {
     
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func insert(_ cache : (feed : [LocalFeedImage], timestamp : Date), to sut : CodableFeedStore){
        let exp = expectation(description: "Wait for cache cache insertion")
        sut.insert(cache.feed, timeStamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetriveTwice expectedResult: RetriveCacheFeedResult, file:StaticString = #file, line:  UInt = #line){
        expect(sut, toRetrive: expectedResult, file: file, line:  line)
        expect(sut, toRetrive: expectedResult, file: file, line:  line)
    }
    private func expect(_ sut: CodableFeedStore, toRetrive expectedResult: RetriveCacheFeedResult, file:StaticString = #file, line:  UInt = #line){
        
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrive { retrievedResult in
           
            switch (expectedResult,retrievedResult) {
            case (.empty,.empty), (.failure,.failure):
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


