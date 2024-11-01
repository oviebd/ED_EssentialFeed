//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 1/11/24.
//

import Foundation
import EssentialFeed
final class FeedViewModel {
  
    private let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    
    private(set) var isloading: Bool = false {
        didSet{ onChange?(self)  }
    }
    
    func loadFeed() {
     
        isloading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isloading = false
        }
    }
}
