//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

//extension LoadFeedResult : Equatable where Error : Equatable{}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
