//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Habibur Rahman on 28/10/24.
//

import XCTest

final class FeedViewController {
    
    init (loder : FeedViewControllerTest.LoaderSpy){
        
    }
}

final class FeedViewControllerTest: XCTestCase {

    func test_initDoesnotLoadFeed(){
        let loader = LoaderSpy()
        _ = FeedViewController(loder: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    
    //MARK: - Helpers
    
    class LoaderSpy{
        private(set) var loadCallCount : Int = 0
    }
    
}
