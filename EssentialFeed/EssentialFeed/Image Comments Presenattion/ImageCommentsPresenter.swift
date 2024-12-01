//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 2/12/24.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                                 tableName: "ImageComments",
                                 bundle: Bundle(for: Self.self),
                                 comment: "title for the Image Comments view")
    }
}
