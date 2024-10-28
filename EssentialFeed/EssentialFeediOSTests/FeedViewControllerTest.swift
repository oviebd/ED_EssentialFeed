//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Habibur Rahman on 28/10/24.
//

import XCTest

final class FeedViewController : UIViewController{
    
    private var loader : FeedViewControllerTest.LoaderSpy?
    convenience init (loader : FeedViewControllerTest.LoaderSpy){
     
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load()
    }
    
    
}

final class FeedViewControllerTest: XCTestCase {

    func test_initDoesnotLoadFeed(){
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadFeed(){
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }

    
    //MARK: - Helpers
    
    class LoaderSpy{
        private(set) var loadCallCount : Int = 0
        
        func load(){
            loadCallCount += 1
        }
    }
    
}
