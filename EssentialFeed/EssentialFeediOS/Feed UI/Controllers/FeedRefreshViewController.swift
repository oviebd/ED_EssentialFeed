//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 31/10/24.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private(set) lazy var view: UIRefreshControl = loadView()

    private let presenter : FeedPresenter
   
    init(presenter : FeedPresenter) {
        self.presenter = presenter
    }

    @objc func refresh() {
        presenter.loadFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        }else{
            view.endRefreshing()
        }
    }
    private func loadView () -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
