//
//  UiButton+ext.swift
//  EssentialAppTests
//
//  Created by Habibur Rahman on 9/12/24.
//

import Foundation
import UIKit

extension UIButton {
    public func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

