//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 9/11/24.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
