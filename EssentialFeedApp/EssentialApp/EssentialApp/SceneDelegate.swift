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
        
        let url = FeedEndpoint.get.url(baseURL: baseURL)
        //URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!

      //  let remoteFeedLoader = httpClient.getPublisher(from: remoteURL).tryMap(FeedItemMapper.map)
        //RemoteLoader(client: httpClient, url: remoteURL, mapper: FeedItemMapper.map)
        
        return httpClient
            .getPublisher(from: url)
            .tryMap(FeedItemMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map{
                Paginated(items: $0)
            }.eraseToAnyPublisher()
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





