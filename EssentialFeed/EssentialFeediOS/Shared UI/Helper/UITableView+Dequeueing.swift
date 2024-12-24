//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 4/11/24.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
