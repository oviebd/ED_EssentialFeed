//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Habibur Rahman on 13/11/24.
//

import CoreData
import EssentialFeed
import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()

    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

    private lazy var navigationController = UINavigationController(
           rootViewController: FeedUIComposer.feedComposedWith(
               feedLoader: makeLocalFeedLoaaderWithLocalFallback,
               imageLoader: makeLocalImageLoaderWithRemoteFallback,
               selection: showComments))
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)

        configureWindow()
    }

    func configureWindow() {
       
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        window?.rootViewController = navigationController

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func showComments(for image: FeedImage) {
           let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
            let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
            navigationController.pushViewController(comments, animated: true)
        }

        private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
            return { [httpClient] in
                return httpClient
                    .getPublisher(from: url)
                    .tryMap(ImageCommentsMapper.map)
                    .eraseToAnyPublisher()
            }
        }
    
    func makeLocalFeedLoaaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error>{
        
        let url = FeedEndpoint.get().url(baseURL: baseURL)
            
        return httpClient
            .getPublisher(from: url)
            .tryMap(FeedItemMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map{ items in
                Paginated(items: items, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: items, last: items.last))
            }.eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
         last.map { lastItem in
             let url = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)
             
             return { [httpClient, localFeedLoader] in
                 httpClient
                     .getPublisher(from: url)
                     .tryMap(FeedItemMapper.map)
                     .map { newItems in
                         let allItems = items + newItems
                         return Paginated(items: allItems, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: allItems, last: newItems.last))
                     }
                     .caching(to: localFeedLoader)
             }
         }
     }
    
    func makeLocalImageLoaderWithRemoteFallback(url : URL) -> FeedImageDataLoader.Publisher {

        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(from: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
        
    }
}

//extension RemoteLoader : FeedLoader where Resource == [FeedImage]{}
//
//public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>
//
//public extension RemoteImageCommentsLoader {
//    convenience init(client: HTTPClient, url: URL) {
//        self.init(client: client, url: url, mapper: ImageCommentsMapper.map)
//    }
//}
//
//public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>
//
//public extension RemoteFeedLoader {
//    convenience init(client: HTTPClient, url: URL) {
//        self.init(client: client, url: url, mapper: FeedItemMapper.map)
//    }
//}





