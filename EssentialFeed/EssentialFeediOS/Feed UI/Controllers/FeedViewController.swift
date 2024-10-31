//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 28/10/24.
//

import EssentialFeed
import UIKit


public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: FeedRefreshViewController?
    
    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
   

    convenience init(feedRefreshController: FeedRefreshViewController) {
        self.init()
        refreshController = feedRefreshController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = refreshController?.view
        

        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }

    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            _ = cellController(forRowAt: indexPath).view()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
