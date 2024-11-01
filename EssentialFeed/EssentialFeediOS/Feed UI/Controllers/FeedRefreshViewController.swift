//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 31/10/24.
//

import UIKit

final class FeedRefreshViewController: NSObject {
   
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())

    private let viewModel : FeedViewModel
   
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view : UIRefreshControl) -> UIRefreshControl{
        viewModel.onChange = { [weak self] viewModel in
           
            if viewModel.isloading {
                self?.view.beginRefreshing()
            }else{
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
