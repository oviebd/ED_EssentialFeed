//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 5/12/24.
//

import Foundation
import UIKit

public struct CellController {
    let id : AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?

    public init(id : AnyHashable, _ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.dataSource = dataSource
        delegate = dataSource
        dataSourcePrefetching = dataSource
        self.id = id
    }
    
    

    public init(id : AnyHashable,_ dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
        self.id = id
        self.delegate = dataSource as? UITableViewDelegate
        self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

extension CellController : Equatable{
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
    
}

extension CellController : Hashable{
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
