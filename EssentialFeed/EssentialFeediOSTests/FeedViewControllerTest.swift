//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Habibur Rahman on 28/10/24.
//

import XCTest
import EssentialFeed

final class FeedViewController : UIViewController{
    
    private var loader : FeedLoader?
    convenience init (loader : FeedLoader){
     
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load{ _ in
            
        }
    }
    
    
}

final class FeedViewControllerTest: XCTestCase {

    func test_initDoesnotLoadFeed(){
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadFeed(){
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }

    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
            let loader = LoaderSpy()
            let sut = FeedViewController(loader: loader)
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, loader)
        }
    
    class LoaderSpy : FeedLoader{
        
        private(set) var loadCallCount : Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
        
    }
    
}
