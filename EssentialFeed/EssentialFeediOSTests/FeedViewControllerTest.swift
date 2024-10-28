//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Habibur Rahman on 28/10/24.
//

import EssentialFeed
import XCTest

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }

    @objc private func load() {
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTest: XCTestCase {
    func test_initDoesnotLoadFeed() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_userInitiatedFeedReload_reloadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

//
//    //ios 17 not support this
//    func test_viewDidLoad_showsLoadingIndicator() {
//        let (sut, _) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        sut.simulateUserInitiatedFeedReload()
//
//       XCTAssertTrue(sut.isShowingLoadingIndicator)
//    }

//    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading()
//
//       XCTAssertFalse(sut.isShowingLoadingIndicator)
//    }

//    func test_userInitiatedFeedReload_showsLoadingIndicator() {
//        let (sut, _) = makeSUT()
//
//        sut.simulateUserInitiatedFeedReload()
//
//        XCTAssertTrue(sut.isShowingLoadingIndicator)
//    }

//    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion() {
//        let (sut, loader) = makeSUT()
//
//        sut.simulateUserInitiatedFeedReload()
//        loader.completeFeedLoading()
//
//        XCTAssertFalse(sut.isShowingLoadingIndicator)
//    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            return completions.count
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeFeedLoading() {
            completions[0](.success([]))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    var isShowingLoadingIndicator: Bool {
            return refreshControl?.isRefreshing == true
        }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
