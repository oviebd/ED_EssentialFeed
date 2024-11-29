//
//   FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Habibur Rahman on 5/11/24.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTest {
    
    
    private class DummyView : ResourceView{
        func display(_ viewModel: Any) {    }
    }
    
    var loadError : String {
        LoadResourcePresenter<Any,DummyView>.loadError
    }
    
    var feedTitle : String {
        FeedPresenter.title
    }
}
