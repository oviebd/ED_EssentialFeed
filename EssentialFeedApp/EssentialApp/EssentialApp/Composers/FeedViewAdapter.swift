//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 6/11/24.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(controller: ListViewController,  imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
                           imageLoader(model.url)
                       })
          
            let view = FeedImageCellController(
                FeedImagePresenter.map(model),
                delegate: adapter)

            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: {data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageData()
                    }
                    
                    return image
                })

            return view
        })
    }
}

private struct InvalidImageData : Error {}
