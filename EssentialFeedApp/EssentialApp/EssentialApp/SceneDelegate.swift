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
       
      
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeLocalFeedLoaaderWithLocalFallback,
                imageLoader: makeLocalImageLoaderWithRemoteFallback(url: )))

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    func makeLocalFeedLoaaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error>{
        
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!

      //  let remoteFeedLoader = httpClient.getPublisher(from: remoteURL).tryMap(FeedItemMapper.map)
        //RemoteLoader(client: httpClient, url: remoteURL, mapper: FeedItemMapper.map)
        
        return httpClient
            .getPublisher(from: remoteURL)
            .tryMap(FeedItemMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    func makeLocalImageLoaderWithRemoteFallback(url : URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader.loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader.loadImageDataPublisher(from: url)
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





