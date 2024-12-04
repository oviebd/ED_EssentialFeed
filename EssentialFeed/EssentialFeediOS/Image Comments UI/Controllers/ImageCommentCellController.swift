//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 4/12/24.
//

import EssentialFeed
import Foundation
import UIKit

public class ImageCommentCellController: CellController {
    private let model: ImageCommentViewModel
    public init(model: ImageCommentViewModel) {
        self.model = model
    }

    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }

    public func preload() {
    }

    public func cancelLoad() {
    }
}
