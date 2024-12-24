//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 30/10/24.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet public private(set) var locationContainer: UIView!
    @IBOutlet public private(set) var locationLabel: UILabel!
    @IBOutlet public private(set) var feedImageContainer: UIView!
    @IBOutlet public private(set) var feedImageView: UIImageView!
    @IBOutlet public private(set) var feedImageRetryButton: UIButton!
    @IBOutlet public private(set) var descriptionLabel: UILabel!

    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        onReuse?()
    }
}
