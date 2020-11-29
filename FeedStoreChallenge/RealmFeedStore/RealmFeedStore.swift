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
    private let queue = DispatchQueue(label: "\(RealmFeedStore.self) queue", qos: .userInitiated)
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async {
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
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let cacheId = RealmFeedStore.cacheId
        queue.async { [weak self] in
            guard let self = self else { return }
            let realm = try! Realm()
            let feedList = feed.map(RealmFeedImage.init)
            let cacheExists = RealmFeedStore.objectExist(realm: realm, id: cacheId)

            do {
                if cacheExists {
                  
                    try self.updateCache(feedList, timestamp, cacheId, realm)

                } else {
                  
                    try self.firstTimeInsertion(feedList, timestamp, cacheId, realm)
                  
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func firstTimeInsertion(_ feedList: [RealmFeedImage], _ timestamp: Date, _ id: String, _ realm: Realm) throws {
        
        let localRealm: Realm = realm
        
        let cache = Cache()
        cache.feed.append(objectsIn: feedList)
        cache.timestamp = timestamp
        cache.id = RealmFeedStore.cacheId
        
        try localRealm.write {
            realm.add(cache)
        }
    }
    
    func updateCache(_ feedList: [RealmFeedImage], _ timestamp: Date, _ id: String, _ realm: Realm) throws {
        
        let localRealm: Realm = realm
        
        try localRealm.write {
          realm.create(
            Cache.self,
            value: [
              "feed": feedList,
              "timestamp": timestamp,
                "id": "\(RealmFeedStore.cacheId)"
            ],
            update: .modified)
        
        }
    }
    
    static func objectExist (realm: Realm, id: String) -> Bool {
        return realm.object(ofType: Cache.self, forPrimaryKey: id) != nil
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        queue.async {
            let realm = try! Realm()
            guard let cache = realm.objects(Cache.self).first else {
                return completion(.empty)
            }
            
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        }
    }
    
    
}
