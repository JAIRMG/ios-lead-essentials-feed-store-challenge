//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Jair Moreno Gaspar on 29/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import RealmSwift

public class RealmFeedStore: FeedStore {
    
    private static let cacheId = "cache"
    private let realm: Realm
    
    public init(configuration: Realm.Configuration) {
        realm = try! Realm(configuration: configuration)
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        guard let cache = realm.objects(Cache.self).first else {
            return completion(nil)
        }
        do {
            try realm.write {
                realm.delete(cache)
            }
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        let feedList = feed.map(RealmFeedImage.init)
        
        do {
            try realm.write {
                realm.deleteAll()
                let cache = Cache()
                cache.feed.append(objectsIn: feedList)
                cache.timestamp = timestamp
                cache.id = RealmFeedStore.cacheId
                realm.add(cache)
            }

            completion(nil)
        } catch {
            completion(error)
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {

        guard let cache = realm.objects(Cache.self).first else {
            return completion(.empty)
        }
        
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    
}
