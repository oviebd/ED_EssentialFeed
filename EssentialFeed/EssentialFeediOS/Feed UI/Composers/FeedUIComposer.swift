//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 31/10/24.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer{
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        
        let feedController = FeedViewController(feedRefreshController: refreshController)
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map{ model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        
        return feedController
    }
}
