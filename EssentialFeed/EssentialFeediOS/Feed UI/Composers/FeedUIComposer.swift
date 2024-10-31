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
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
            return { [weak controller] feed in
                controller?.tableModel = feed.map { model in
                    FeedImageCellController(model: model, imageLoader: loader)
                }
            }
        }
}
