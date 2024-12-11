//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Habibur Rahman on 9/12/24.
//

import Combine
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import XCTest

final class CommentsUIIntegrationTests: XCTestCase {
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.title, commentsTitle)
    }

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a description", username: "a location")
        let comment1 = makeComment(message: "another description", username: "another isername")

        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment0 = makeComment()
        let comment1 = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 0)
        assertThat(sut, isRendering: [comment0, comment1])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }

    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }

    func test_loadCommentCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadCommentCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_deinit_cancelsRunningRequest() {
           var cancelCallCount = 0

           var sut: ListViewController?

           autoreleasepool {
                sut = CommentsUIComposer.commentsComposedWith(commentsLoader: {
                   PassthroughSubject<[ImageComment], Error>()
                       .handleEvents(receiveCancel: {
                           cancelCallCount += 1
                       }).eraseToAnyPublisher()
               })

               sut?.loadViewIfNeeded()
           }

           XCTAssertEqual(cancelCallCount, 0)

           sut = nil

           XCTAssertEqual(cancelCallCount, 1)
       }


    // MARK: - Helpers

    private func makeComment(message: String = "any message", username: String = "a username", url: URL = URL(string: "http://any-url.com")!) -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

//    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
//        sut.view.enforceLayoutCycle()
//
//        guard sut.numberOfRenderedFeedImageViews() == comments.count else {
//            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
//        }
//
//        comments.enumerated().forEach { index, image in
//            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
//        }
//    }

    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)

        let viewModel = ImageCommentsPresenter.map(comments)

        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
        }
    }

    class LoaderSpy {
        // MARK: - FeedLoader

        private var requests = [PassthroughSubject<[ImageComment], Error>]()

        var loadCommentsCallCount: Int {
            return requests.count
        }

        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
        }

        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}

// extension FeedImageCell {
//    var isShowingLocation: Bool {
//        return !locationContainer.isHidden
//    }
//
//    var locationText: String? {
//        return locationLabel.text
//    }
//
//    var descriptionText: String? {
//        return descriptionLabel.text
//    }
//
//    var isShowingImageLoadingIndicator: Bool {
//        return feedImageContainer.isShimmering
//    }
//
//    var renderedImage: Data? {
//        return feedImageView.image?.pngData()
//    }
//
//    var isShowingRetryAction: Bool {
//        return !feedImageRetryButton.isHidden
//    }
//
//    func simulateRetryAction() {
//        feedImageRetryButton.simulateTap()
//    }
// }
