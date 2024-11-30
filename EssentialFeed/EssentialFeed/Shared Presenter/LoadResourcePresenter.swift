//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 29/11/24.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel

    private let errorView: ResourceErrorView
    private var loadingView: ResourceLoadingView
    private let mapper: Mapper
    var resourceView: View

    public init(resourceView: View, loadingView: ResourceLoadingView, errorView: ResourceErrorView, mapper: @escaping Mapper) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }

    public static var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Error message displayed when we can't load the resource from the server")
    }

    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }

    public func didFinishLoading(with errro: Error) {
        errorView.display(.error(message: LoadResourcePresenter<Resource, View>.loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
