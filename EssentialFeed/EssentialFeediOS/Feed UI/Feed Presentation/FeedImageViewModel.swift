//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 1/11/24.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}
