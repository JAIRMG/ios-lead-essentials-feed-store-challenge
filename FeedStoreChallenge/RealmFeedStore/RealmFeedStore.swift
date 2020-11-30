//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Jair Moreno Gaspar on 29/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import RealmSwift

public class RealmFeedStore: FeedStore {
    
    public init() { }
    
    private static let cacheId = "cache"
    private let queue = DispatchQueue(label: "\(RealmFeedStore.self) queue", qos: .userInitiated, attributes: .concurrent)
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let realm = try! Realm()
        
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
        let realm = try! Realm()
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
        let realm = try! Realm()
        guard let cache = realm.objects(Cache.self).first else {
            return completion(.empty)
        }
        
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    
}
