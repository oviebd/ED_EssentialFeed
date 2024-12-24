//
//  UIRefreshControl+Ext.swift
//  EssentialAppTests
//
//  Created by Habibur Rahman on 9/12/24.
//

import Foundation
import UIKit

extension UIRefreshControl {
    public func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
