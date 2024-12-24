//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Habibur Rahman on 20/11/24.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
